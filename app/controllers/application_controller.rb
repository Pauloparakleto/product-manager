class ApplicationController < ActionController::API
    ADJUST_OFFSET_TO_ACT_AS_BOOK_PAGE = 1
    LIMIT_DEFAULT = 20
    FIRST_PAGE_DEFAULT = 1

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
        page = params.fetch("page", FIRST_PAGE_DEFAULT).to_i - ADJUST_OFFSET_TO_ACT_AS_BOOK_PAGE
        page * set_minor_limit
    end

    def set_minor_limit
        [
          params.fetch("limit", LIMIT_DEFAULT).to_i,
          100
        ].min
    end
end
