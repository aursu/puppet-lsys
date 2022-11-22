type Lsys::Resolv::Option = Variant[
  Enum[
    'debug',
    'rotate',
    'no-check-names',
    'inet6',
    'ip6-bytestring',
    'ip6-dotint',
    'no-ip6-dotint',
    'edns0',
    'single-request',
    'single-request-reopen',
    'no-tld-query',
    'use-vc',
    'no-reload'
  ],
  Variant[
    Struct[
      {
        'ndots' => Integer[1, 15]
      }
    ],
    Pattern[/^ndots:([1-9]|1[0-5])$/]
  ],
  Variant[
    Struct[
      {
        'timeout' => Integer[1, 30]
      }
    ],
    Pattern[/^timeout:([1-9]|[1-2][0-9]|30)$/]
  ],
  Variant[
    Struct[
      {
        'attempts' => Integer[1, 5]
      }
    ],
    Pattern[/^attempts:[1-5]$/]
  ]
]
