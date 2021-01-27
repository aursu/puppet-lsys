type Lsys::PackageVersion  = Variant[
  Boolean,
  Pattern[/^[0-9]+/],
  Lsys::Ensure::Package,
]
