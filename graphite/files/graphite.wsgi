# You may need to manually edit this file to fit your needs.
# This configuration assumes the default installation prefix
# of /opt/graphite/, if you installed graphite somewhere else
# you will need to change all the occurances of /opt/graphite/
# in this file to your chosen install location.

import os
import sys 
sys.path.insert(0, '/opt/graphite/webapp/') 
os.environ['DJANGO_SETTINGS_MODULE'] = 'graphite.settings' 
 
import django.core.handlers.wsgi 
 
_application = django.core.handlers.wsgi.WSGIHandler() 
 
def application(environ, start_response): 
    environ['PATH_INFO'] = environ['SCRIPT_NAME'] + environ['PATH_INFO'] 
    return _application(environ, start_response)

