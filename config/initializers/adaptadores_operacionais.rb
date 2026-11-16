# Rails.configuration.x cria OrderedOptions para chaves ausentes. Inicializar
# explicitamente evita que um objeto vazio seja tratado como adaptador configurado.
Rails.application.config.x.provedor_pagamento = nil
Rails.application.config.x.dispositivo_catraca = nil
