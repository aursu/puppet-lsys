# EPEL Yum repository installation
#
# @summary EPEL Yum repository installation
#
# @example
#   include lsys::repo::epel
class lsys::repo::epel {
  contain bsys::repo::epel
}
