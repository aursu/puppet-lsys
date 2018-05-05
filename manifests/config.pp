# lsys::config
#
# A description of what this defined type does
#
# @summary A short summary of the purpose of this defined type.
#
# @example
#   
#   lsys::config { '/etc/GeoIP.conf':
#       data              => {
#           'LicenseKey' => $license_key,
#           'UserId'     => $user_id,
#           'ProductIds' => $product_ids,
#       },
#       key_val_separator => ' ',
#       require           => Package['GeoIP'],
#   }
#
#   $conf_data = {
#       'commands/update_cmd'       => $update_cmd,
#       'commands/update_messages'  => 'yes',
#       'commands/download_updates' => 'yes',
#       'commands/apply_updates'    => $apply_updates,
#       'base/assumeyes'            => 'True',
#   }
#   $yumcron_config = [ '/etc/yum/yum-cron.conf', '/etc/yum/yum-cron-hourly.conf' ]
#   lsys::config { $yumcron_config:
#       data    => $conf_data,
#       require => Package['yum-cron']
#   }
#
#   lsys::config { '/etc/nova/nova.conf/neutron':
#       path    => '/etc/nova/nova.conf',
#       data    => {
#           'neutron/url'                           => "http://${controller}:9696",
#           'neutron/auth_url'                      => "http://${controller}:35357",
#           'neutron/region_name'                   => 'RegionOne',
#           'neutron/project_name'                  => 'service',
#           'neutron/username'                      => 'neutron',
#           'neutron/password'                      => $neutron_pass,
#           'neutron/auth_type'                     => 'password',
#           'neutron/project_domain_name'           => 'default',
#           'neutron/user_domain_name'              => 'default',
#        },
#        require => Lsys::Config['/etc/nova/nova.conf'],
#        notify  => Exec['nova-compute-restart'],
#   }
#
define lsys::config(
    Hash[ String,
        Variant[ String,
            Struct[{
                value                       => String,
                Optional[require]           => Type,
                Optional[notify]            => Type,
                Optional[ensure]            => Enum[present, absent],
                Optional[path]              => String,
                Optional[section_prefix]    => String,
                Optional[section_suffix]    => String,
                Optional[indent_char]       => String,
                Optional[indent_width]      => Integer,
                Optional[show_diff]         => Variant[
                    Boolean,
                    Enum['md5'],
                ],
            }]
        ], 1 ]  $data,
    String      $path               = $name,
    String      $key_val_separator  = ' = ',
)
{
    $data.each | String $key, $value | {
        if '/' in $key {
            $location = split($key, '/')
        }
        else {
            $location = [ '', $key ]
        }
        $attributes = $value ? {
            String  => { value => $value },
            default => $value
        }
        ini_setting {
            "${path}/${key}": * => {
                section           => $location[0],
                setting           => $location[1],
                key_val_separator => $key_val_separator
            } + $attributes;
            default: * => {
                ensure => present,
                path   =>  $path,
            };
        }
    }
}
