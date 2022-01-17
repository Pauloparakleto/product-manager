class ApplicationController < ActionController::API
    ADJUST_OFFSET_TO_ACT_AS_BOOK_PAGE = 1
    LIMIT_DEFAULT = 20
    FIRST_PAGE_DEFAULT = 1
    MAX_LIMIT_PER_PAGE = 100

    def sort_by_param
        set_sort_by_params
    end

    def page_params
        set_page_params
    end

    def params_limit
        set_minor_limit
    end

    def set_header_with_pagination
        return response.set_header("Count-Pages-Total", 1) if count_queries <= params_limit
    
        count_pages = (count_queries / params_limit)
        remaining_page = count_pages%params_limit
        count_pages += 1 unless remaining_page.zero?
        response.set_header("Count-Pages-Total", count_pages)
      end

    private

    def count_queries
        @query.result.count
    end

    def set_sort_by_params
        sort_by_column_name = params.fetch("sort_by", "id")
        sort_option = params.fetch("sort_option", "asc").to_sym
        { "#{sort_by_column_name}": sort_option}
    end

    def set_page_params
        page = params.fetch("page", FIRST_PAGE_DEFAULT).to_i - ADJUST_OFFSET_TO_ACT_AS_BOOK_PAGE
        page * set_minor_limit
    end

    def set_minor_limit
        [
          params.fetch("limit", LIMIT_DEFAULT).to_i,
          MAX_LIMIT_PER_PAGE
        ].min
    end
end
