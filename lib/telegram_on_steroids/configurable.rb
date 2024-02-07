module TelegramOnSteroids
  module Configurable
    def configure(&block)
      define_method(:configure!) do
        instance_eval { block.call(self) }
      end

      define_method(:after_initialize) do
        configure!
      end
    end

    def callable(name)
      attr_writer(name)

      define_method(name) do
        var = instance_variable_get("@#{name.to_s}")
        var.is_a?(Proc) ? instance_eval(&var) : var
      end
    end
  end
end
