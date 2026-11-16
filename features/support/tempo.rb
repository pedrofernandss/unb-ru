# Disponibiliza travel_to/freeze_time nos steps e restaura o relógio ao fim
# de cada cenário.
require "active_support/testing/time_helpers"

World(ActiveSupport::Testing::TimeHelpers)

After { travel_back }
