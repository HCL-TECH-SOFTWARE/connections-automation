#!/usr/bin/env python3

# Run this program on

import urllib.request, urllib.error, urllib.parse
import ssl
import os
import subprocess
import socket
import argparse
import base64

class KubectlError(Exception):
    pass

def set_config(config_url, username, password, settings, skipSslCertCheck):
    settings = bytes(settings, "utf-8")
    print(('Updating Metrics settings on: %s' % config_url))

    try:
        data = settings

        print(data)
        
        # skip SSL certificate checking if requested
        if (skipSslCertCheck):
            ctx = ssl.create_default_context()
            ctx.check_hostname = False
            ctx.verify_mode = ssl.CERT_NONE

#! HTTPPasswordMgrWithDefaultRealm Basic authentication is not working  
#! Don't know why.  Manually constructing the Authorization header below      
        ## set up basic authentication
#!        passman = urllib2.HTTPPasswordMgrWithDefaultRealm()
#!        passman.add_password(None, config_url, username, password)
        
#!        handler = urllib2.HTTPBasicAuthHandler(passman)

        # create "opener" (OpenerDirector instance)
#!        opener = urllib2.build_opener(handler)

        # Install the opener.
        # Now all calls to urllib2.urlopen use our opener.
#!        urllib2.install_opener(opener)

    # Post the new config settings      

        # params = urllib.parse.urlencode({config_url})
        req = urllib.request.Request(url = config_url, data = data)
        string = '%s:%s' % (username, password)
        base64string = base64.b64encode(string.encode('utf-8',errors = 'strict'))
        authheader =  "Basic %s" % base64string.decode("utf-8")
        req.add_header("Authorization", authheader)
        req.add_header('Content-Type', 'application/json')
        req.add_header('X-Update-Nonce', 'PinkAdminRequestToBlue')
        if (skipSslCertCheck):
            response = urllib.request.urlopen(req, context=ctx)
        else:
            response = urllib.request.urlopen(req)
        text = response.read()
        if response.getcode() != 200:
            print(text)
        response.close()
    except urllib.error.URLError as ue:
        print(('%s' % ue))

def update_blue(bluehost, pinkhost, port, port7, user, password, noSslForES, skipSslCertCheck):
    bluehost = bluehost.decode("utf-8")
    if port is not None:
      port = port.decode("utf-8")
    if port7 is not None:
      port7 = port7.decode("utf-8")
    user = user.decode("utf-8")
    password = password.decode("utf-8")
    config_url = 'https://%s/metrics/configsetter' % bluehost

    settings = "{" 
    #! Here we are deciding the url for ES5 if it is available on the server
    if port is not None:
        elasticsearch_baseurl = "https://"
        if noSslForES:
            elasticsearch_baseurl = "http://"
        elasticsearch_baseurl = elasticsearch_baseurl + pinkhost + ":" + port

        settings = settings + "\"c2.export.elasticsearch.baseurl\" : \"%s\"" % elasticsearch_baseurl  
    
    #! Here we are deciding the url for ES7 if it is available on the server
    if port7 is not None:
        elasticsearch_baseurl7 = "https://"
        if noSslForES:
            elasticsearch_baseurl7 = "http://"
        elasticsearch_baseurl7 = elasticsearch_baseurl7 + pinkhost + ":" + port7
        
        #! Concatenating the ES7 url with comma if ES5 also exist else only ES7 URL is going to be set in highway client
        if port is not None:
            settings = settings + ",\n" 
        settings = settings + "\"c2.export.elasticsearch.baseurl7\" : \"%s\"" % elasticsearch_baseurl7
    settings = settings + "}"
    
    #! If both ES5 and ES7 is not available on the server then no need to set anything in Highway client
    if port is not None or port7 is not None:
        set_config(config_url, user, password, settings, skipSslCertCheck)

def get_k8s_service_port(namespace, svc):
    cmd = ['kubectl', 'get', 'svc', svc, '--namespace', namespace,
           '-o', 'jsonpath={.spec.ports[*].nodePort}']
    proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=False)
    (out, err) = proc.communicate()
    if proc.returncode != 0:
        string = 'services "%s" not found' % (svc)
        not_found_err = base64.b64encode(string.encode('utf-8',errors = 'strict'))
        if not_found_err in err:
            print("Warning " + svc + " not found in Kubernetes.")
            return None
        try:
            raise KubectlError(err)
        except:
            print("Warning " + svc + " not found in Kubernetes.")
            return None
    return out
    
def get_ic_host(namespace):
    configmap = 'connections-env'
    cmd = ['kubectl', 'get', 'configmaps', configmap, '--namespace', namespace,
           '-o', 'jsonpath={.data.ic-host}']
    proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, shell=False)
    (out, err) = proc.communicate()
    if proc.returncode != 0:
        raise KubectlError(err)
        
    return out

def get_k8s_secret(namespace, secret, jsonpath):
    cmd = ['kubectl', 'get', 'secret', secret, '--namespace', namespace,
           '-o', 'jsonpath={'+jsonpath+'}']
    proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, shell=False)
    (out, err) = proc.communicate()
    if proc.returncode != 0:
        raise KubectlError(err)

    data = base64.b64decode(out)

    return data

#! Below method will check whether kubectl is installed or not.
def get_k8s_installed():
    cmd = ['kubectl', 'get', 'nodes']
    proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=False)
    (out, err) = proc.communicate()
    if proc.returncode != 0:
        print("kubectl needs to be set before you can proceed")
        return False
    return True
    
def main():
    this_host = socket.gethostname()
    parser = argparse.ArgumentParser(
    description='Update Connections Blue with Pink ElasticSearch server info.')
    parser.add_argument('--pinkhost', action='store', help='Pink host (default: '+this_host+')', default=this_host)
    parser.add_argument('--namespace', action='store', help='Kubernetes namespace (default: connections)', default='connections')
    parser.add_argument('--noSslForElasticSearch', action='store', help='Used to force the ElasticSearch baseurl to be plain http - unsafe.  (default: false)', default=False)
    parser.add_argument('--skipSslCertCheck', action='store', help='Used to accept self-signed certificates from WebSphere (default: false)', default=False)
    parser.add_argument('-v', '--verbose', action='store_true', dest='verbose', default=False,
                        help='Verbose. (default: false)')
    args = parser.parse_args()
    if get_k8s_installed():
        ic_host = get_ic_host(args.namespace)
        port = get_k8s_service_port(args.namespace, 'elasticsearch')
        port7 = get_k8s_service_port(args.namespace, 'opensearch-cluster-master')
        if port7 is None:
                port7 = get_k8s_service_port(args.namespace, 'elasticsearch7')
        
        user = get_k8s_secret(args.namespace, 'ic-admin-secret','.data.uid')
        password = get_k8s_secret(args.namespace, 'ic-admin-secret','.data.password')
        
        update_blue(ic_host, args.pinkhost, port, port7, user, password, args.noSslForElasticSearch, args.skipSslCertCheck)


if __name__ == '__main__':
    main()
