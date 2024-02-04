module TelegramOnSteroids
  module Keyboards
    module Paginatable
      def paginatable
        true
      end

      def to_telegram_format
        return [buttons] if first_page? && last_page?

        [buttons[offset...offset + per_page]].push(navigation_buttons)
      end

      def navigation_buttons
        return [prev_button] if last_page?
        return [next_button] if first_page?

        [prev_button, next_button]
      end

      def per_page
        @per_page ||= 2
      end

      def per_page=(val)
        @per_page = val
      end

      def current_page
        return 1 unless request.params.callback_data =~ /page/

        request.params.callback_data.scan(/\d+/).first.to_i
      end

      def offset
        (current_page - 1) * per_page
      end

      def last_page?
        current_page * per_page >= buttons.size
      end

      def first_page?
        current_page == 1
      end

      def prev_button
        { text: '<< Prev', callback_data: "page_#{current_page - 1}" }
      end

      def next_button
        { text: 'Next >>', callback_data: "page_#{current_page + 1}" }
      end
    end
  end
end
