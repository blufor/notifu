##
# Require block
#
require "ohm"
require "elasticsearch"
require "log4r/outputter/syslogoutputter"
require "log4r/configurator"
require "log4r"
require "syslog"
require "sidekiq"
require "sidekiq/logging"
require "notifu"

##
# Config block
#
Notifu::CONFIG = Notifu::Config.new.get

##
# Ohm init
#
Ohm.redis = Redic.new Notifu::CONFIG[:redis_data]
