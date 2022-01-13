class ApplicationController < ActionController::API
    def sort_by_param
        set_sort_by_params
    end

    def page_params
        set_page_params
    end

    def params_limit
        set_minor_limit
    end

    private

    def set_sort_by_params
        params.fetch("sort_by", "id").to_sym
    end

    def set_page_params
        page = params.fetch("page", 1).to_i - 1
        page * set_minor_limit
    end

    def set_minor_limit
        [
          params.fetch("limit", 20).to_i,
          100
        ].min
    end
end
