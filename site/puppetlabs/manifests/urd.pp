class puppetlabs::urd {
  include puppetlabs::lan
  include pkgs::admin
  include yum::mirror
  include pxe
  include jumpstart

  ssh::allowgroup   { "interns": }
  sudo::allowgroup  { "interns": }

}