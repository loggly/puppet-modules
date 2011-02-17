#!/usr/bin/env python
from rightscale import RightScale
import sys
rsapi = RightScale(ACCOUNTID, USERNAME, PASSWORD)

myself = rsapi.whoami()

if myself is None:
  print >>sys.stderr, "This system is not found in RightScale."
  exit(1)
  

# Find all servers (including myself) in my deployment.
servers = [s for s in rsapi.servers if s.deployment_href == myself.deployment_href]

tagged = dict()
for server in servers:
  #print server
  #print server.tags
  for tag in server.tags:
    #print tag
    tagged.setdefault(tag.name, list())
    tagged[tag.name].append(server)

data = dict()

data["deployment"] = myself.deployment.nickname
data["name"] = myself.nickname
data["servers"] = dict()
for server in servers:
  data["servers"][server.nickname] = {
    "ip_address": server.settings.ip_address,
    "private_ip_address": server.settings.private_ip_address,
    "tags": [t.name for t in server.tags],
  }

#data["tags"] = dict()
#for tag,tagged_servers in tagged.iteritems():
  #data["tags"][tag] = [s.nickname for s in tagged_servers]

import json
# Pretty-print the json so it's easily human-readable
print json.dumps(data, indent=2)
