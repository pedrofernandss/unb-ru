# Por padrão o Rails envolve campos inválidos em <div class="field_with_errors">,
# o que quebra o layout dos campos com ícone. As views marcam o erro com a classe
# "campo--erro" no contêiner do campo.
ActionView::Base.field_error_proc = proc { |html_tag, _instance| html_tag }
