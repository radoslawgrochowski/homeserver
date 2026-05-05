var REG_OVH = NewRegistrar('ovh')
var DNS_OVH = NewDnsProvider('ovh')

DEFAULTS(DefaultTTL('1h'), NAMESERVER_TTL('1h'))

D('fard.pl', REG_OVH, DnsProvider(DNS_OVH), [
  NAMESERVER('dns109.ovh.net.'),
  NAMESERVER('ns109.ovh.net.'),

  A('@', '212.91.26.153'),

  A('portkey', '154.46.30.187'),
  CNAME('*', 'portkey.fard.pl.'),
  CNAME('*.portkey', 'portkey.fard.pl.'),

  IGNORE('nimbus'),
  CNAME('*.nimbus', 'nimbus.fard.pl.'),

  MX('@', 10, 'mail0.mydevil.net.'),

  SPF_BUILDER({ parts: ['v=spf1', 'mx', 'a', 'include:mail0.mydevil.net', '-all'] }),
])
