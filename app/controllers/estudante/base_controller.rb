module Estudante
  # Controllers do Portal do Estudante: exigem login e usam o layout "estudante".
  class BaseController < ApplicationController
    layout "estudante"
  end
end
