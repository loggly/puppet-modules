import zerigodns
import json
import re
import sys

def safe_hostname(value):
  return re.compile("[^A-Za-z0-9-]").sub("_", value).lower()

class ZerigoUpdater(object):
  api_user = "zerigo_api_user"
  api_key  = "zerigo_api_key"
  def __init__(self, api_user, api_key):
    self.api_user = api_user
    self.api_key = api_key
    self.zerigo = zerigodns.NSZone(self.api_user, self.api_key)
  # def __init__

  def zone(self, domain):
    try:
      return self.zerigo.find_by_domain(domain)
    except zerigodns.api.ZerigoNotFound, e:
      return self.zerigo.create({ "domain": domain })
  # def zone

  def update(self, domain, truthdata):
    zone = self.zone(domain)
    self.update_hosts(zone, truthdata)
    #self.update_roles(zone, truthdata)
  # def update

  def update_hosts(self, zone, truthdata):
    oldhosts = {}
    notes = "host"
    ttl = 60

    for host in zone.hosts:
      if host.host_type == "A" and host.hostname is not None:
        oldhosts[host.hostname] = host

    for name, info in truth["servers"].iteritems():
      if "ip_address" not in info:
        print "%s has no public ip, skipping" % (name)
        continue
      public_ip = info["ip_address"]
      real_hostname = "%s" % (safe_hostname(name))

      # Give wildcards for all.
      hostnames = [real_hostname]
      #if "role:frontend=true" in info["tags"]:
      hostnames.append("*.%s" % real_hostname)
      for hostname in hostnames:
        if hostname in oldhosts:
          current = oldhosts[hostname]
          tainted = False
          if current.data != public_ip:
            print "%s.%s: IP updated" % (hostname, zone.domain)
            current.data = public_ip
            tainted = True
          if current.notes != notes:
            print "%s.%s: notes updated" % (hostname, zone.domain)
            current.notes = notes
            tainted = True
          if current.ttl != ttl:
            print "%s.%s: ttl updated" % (hostname, zone.domain)
            current.ttl = ttl
            tainted = True

          if tainted:
            print "Updating: %s.%s" % (hostname, zone.domain)
            current.save()
          del oldhosts[hostname]
        else:
          print "Creating: %s.%s" % (hostname, zone.domain)
          zone.create_host({ "hostname": hostname, "ttl": 60,
                              "host-type": "A", "data": public_ip,
                              "notes": notes })

    for missing in oldhosts.itervalues():
      # Skipp non-host entries
      if missing.notes != "host":
        continue
      print "Removing unknown host in '%s' deployment: %s" % (deployment, missing.hostname)
      missing.destroy()
  # def update_hosts

  def update_roles(self, zone, truthdata):
    oldhosts = {}
    notes = "role"
    ttl = 60

    # In these cases, 'host' is often 'role'
    for host in zone.hosts:
      if host.host_type == "A" and host.hostname is not None:
        oldhosts.setdefault(host.hostname, list())
        oldhosts[host.hostname].append(host)

    # build list of roles for all servers
    role_re = re.compile("^role:([^=]+)=true$")
    for name, info in truth["servers"].iteritems():
      for tag in info.tags:
        m = role_re.match(tag)
        if m:
          role = m.groups()[0]
          roles.setdefault(role, {})
          roles[role][name] = info

    for role, servers in roles.iteritems():
      seen_ips = self.update_role(role, zone, servers)
      for ip in seen_ips:
        oldhosts[role].remove(ip)
  # def update_roles

  def update_role(self, role, zone, servers):
    seen = list()
    hostname = role
    # servers is a
    for name, info in servers.iteritems():
        # See if this dns entry is defined, update or create as necessary
      public_ip = info["ip_address"]

      current = oldhosts[hostname]
      tainted = False
      if current.data != public_ip:
        print "%s.%s: IP updated" % (hostname, zone.domain)
        current.data = public_ip
        tainted = True
      if current.notes != notes:
        print "%s.%s: notes updated" % (hostname, zone.domain)
        current.notes = notes
        tainted = True
      if current.ttl != ttl:
        print "%s.%s: ttl updated" % (hostname, zone.domain)
        current.ttl = ttl
        tainted = True

      if tainted:
        print "Updating: %s.%s" % (hostname, zone.domain)
        current.save()
      del oldhosts[hostname]
    else:
      # If the entry was not found, create it.
      print "Creating: %s.%s" % (hostname, zone.domain)
      zone.create_host({ "hostname": hostname, "ttl": 60,
                          "host-type": "A", "data": public_ip,
                          "notes": notes })
    for missing in oldhosts.itervalues():
      # Skipp non-host entries
      if missing.notes != "host":
        continue
      print "Removing unknown host in '%s' deployment: %s" % (deployment, missing.hostname)
      missing.destroy()
  # def update_role
# class ZerigoUpdater

truth = json.loads(file("/etc/truth.json").read())
deployment = truth["deployment"]

domain = "%s.example.com" % safe_hostname(deployment)
zup = ZerigoUpdater("USER", "APIKEY")
zup.update(domain, truth)
