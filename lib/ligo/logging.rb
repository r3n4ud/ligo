# -*- coding: utf-8; fill-column: 80 -*-
#
# Copyright (c) 2012, 2013 Renaud AUBIN
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'logger'

module Ligo

  # Logging module
  #
  # This module enables to share the same logger between all the Ligo classes.
  module Logging

    def logger
      @logger ||= Logging.logger_for(self.class.name)
    end

    # Use a hash class-ivar to cache a unique Logger per class:
    @loggers = {}
    @out = STDOUT

    class << self
      def logger_for(classname)
        @loggers[classname] ||= configure_logger_for(classname)
      end

      def configure_logger_for(classname)
        logger = Logger.new(@out)
        logger.progname = classname
        logger
      end

      #
      def configure_logger_output(logout)
        @out = logout if logout != 'STDOUT'
      end
    end

  end

end
