module Api
  module V2
    class WorksController < V2::BaseController
      layout 'api/v2/layouts/index_without_count', only: :index

      api :GET, '/works', 'List works'
      param_group :pagination, V2::BaseController
      param :is_eebo, :boolean, desc: 'Filter by EEBO Works'
      param :is_ecco, :boolean, desc: 'Filter by ECCO Works'
      param :batch_job_id, Integer, desc: 'Filter by BatchJob ID'
      param :wks_book_id, String, desc: 'Work wks_book_id'
      param :language_id, Integer, desc: 'Work language_id'
      def index
        @works = Work.page(paginate_params[:page_num]).per(paginate_params[:per_page])
        if query_params[:wks_book_id].present?
          @works = @works.where(wks_book_id: query_params[:wks_book_id])
        end
        if query_params[:language_id].present?
          @works = @works.where(language_id: query_params[:language_id])
        end
        if query_params.key?(:is_ecco) && query_params[:is_ecco].to_bool
          @works = @works.is_ecco
        end
        if query_params.key?(:is_eebo) && query_params[:is_eebo].to_bool
          @works = @works.is_eebo
        end
        if query_params.key?(:batch_job_id)
          @works = @works.joins(:batch_jobs).where(batch_jobs: { id: query_params[:batch_job_id] }).distinct
          #@works = @works.includes(:batch_jobs).where(batch_jobs: { id: query_params[:batch_job_id] })
        end

        respond_with @works
      end

      api :GET, '/works/:id', 'Show a work'
      param :id, Integer, desc: 'Work ID', required: true
      def show
        super
      end

      api :POST, '/works', 'Create a work'
      param :work, Hash, required: true do
        param :collection_id, Integer
        param :language_id, Integer
        param :wks_gt_number, String
        param :wks_estc_number, String
        param :wks_coll_name, String
        param :wks_tcp_bibno, Integer
        param :wks_marc_record, String
        param :wks_eebo_citation_id, Integer
        param :wks_doc_directory, String
        param :wks_ecco_number, String
        param :wks_book_id, String
        param :wks_author, String
        param :wks_printer, String
        param :wks_word_count, Integer
        param :wks_title, String
        param :wks_eebo_image_id, String
        param :wks_eebo_url, String
        param :wks_pub_date, String
        param :wks_ecco_uncorrected_gale_ocr_path, String
        param :wks_corrected_xml_path, String
        param :wks_corrected_text_path, String
        param :wks_ecco_directory, String
        param :wks_ecco_gale_ocr_xml_path, String
        param :wks_organizational_unit, Integer
        param :wks_primary_print_font, Integer
        param :wks_last_trawled, String
      end
      def create
        super
      end

      api :POST, '/works/create_bulk', 'Create multiple works'
      param :works, Array, 'Works', required: true do
        param :wks_work_id, Integer
        param :collection_id, Integer
        param :language_id, Integer
        param :wks_gt_number, String
        param :wks_estc_number, String
        param :wks_coll_name, String
        param :wks_tcp_bibno, Integer
        param :wks_marc_record, String
        param :wks_eebo_citation_id, Integer
        param :wks_doc_directory, String
        param :wks_ecco_number, String
        param :wks_book_id, String
        param :wks_author, String
        param :wks_printer, String
        param :wks_word_count, Integer
        param :wks_title, String
        param :wks_eebo_image_id, String
        param :wks_eebo_url, String
        param :wks_pub_date, String
        param :wks_ecco_uncorrected_gale_ocr_path, String
        param :wks_corrected_xml_path, String
        param :wks_corrected_text_path, String
        param :wks_ecco_directory, String
        param :wks_ecco_gale_ocr_xml_path, String
        param :wks_organizational_unit, Integer
        param :wks_primary_print_font, Integer
        param :wks_last_trawled, String
      end
      def create_bulk
        works = params[:works]
        new_works = []
        @up_to_date = 0
        @updated_success = 0
        @updated_failed = 0
        works.each do |w|
          params = work_bulk_params(w)
          conditions = { wks_work_id: params[:wks_work_id], wks_book_id: params[:wks_book_id] }
          @work = Work.where(conditions).first_or_initialize
          if @work.new_record?
            new_works << Work.new(params)
          else
            if Work.exists?(params)
              @up_to_date += 1
              next
            end
            if @work.update_attributes(params)
              @updated_success += 1
            else
              @updated_failed += 1
            end
          end
        end

        count_before = Work.count
        @works = Work.import(new_works)
        count_after = Work.count
        @imported = count_after - count_before
      end

      api :PUT, '/works/:id', 'Update a work'
      param :work, Hash, required: true do
        param :collection_id, Integer
        param :language_id, Integer
        param :wks_gt_number, String
        param :wks_estc_number, String
        param :wks_coll_name, String
        param :wks_tcp_bibno, Integer
        param :wks_marc_record, String
        param :wks_eebo_citation_id, Integer
        param :wks_doc_directory, String
        param :wks_ecco_number, String
        param :wks_book_id, String
        param :wks_author, String
        param :wks_printer, String
        param :wks_word_count, Integer
        param :wks_title, String
        param :wks_eebo_image_id, String
        param :wks_eebo_url, String
        param :wks_pub_date, String
        param :wks_ecco_uncorrected_gale_ocr_path, String
        param :wks_corrected_xml_path, String
        param :wks_corrected_text_path, String
        param :wks_ecco_directory, String
        param :wks_ecco_gale_ocr_xml_path, String
        param :wks_organizational_unit, Integer
        param :wks_primary_print_font, Integer
        param :wks_last_trawled, String
      end
      def update
        super
      end

      api :DELETE, '/works/:id', 'Delete a work'
      param :id, Integer, desc: 'Work ID', required: true
      def destroy
        super
      end

      private

      def work_params
        params.require(:work).permit(:collection_id, :language_id, :wks_gt_number, :wks_estc_number, :wks_coll_name, :wks_tcp_bibno, :wks_marc_record,
          :wks_eebo_citation_id, :wks_doc_directory,
          :wks_ecco_number, :wks_book_id, :wks_author, :wks_printer, :wks_word_count, :wks_title, :wks_eebo_image_id, :wks_eebo_url, :wks_pub_date,
          :wks_ecco_uncorrected_gale_ocr_path, :wks_corrected_xml_path, :wks_corrected_text_path, :wks_ecco_directory, :wks_ecco_gale_ocr_xml_path,
          :wks_organizational_unit, :wks_primary_print_font, :wks_last_trawled)
      end

      def work_bulk_params(work)
        work.permit(:wks_work_id, :collection_id, :language_id, :wks_gt_number, :wks_estc_number, :wks_coll_name, :wks_tcp_bibno, :wks_marc_record,
          :wks_eebo_citation_id, :wks_doc_directory,
          :wks_ecco_number, :wks_book_id, :wks_author, :wks_printer, :wks_word_count, :wks_title, :wks_eebo_image_id, :wks_eebo_url, :wks_pub_date,
          :wks_ecco_uncorrected_gale_ocr_path, :wks_corrected_xml_path, :wks_corrected_text_path, :wks_ecco_directory, :wks_ecco_gale_ocr_xml_path,
          :wks_organizational_unit, :wks_primary_print_font, :wks_last_trawled)
      end

      def query_params
        params.permit(:is_eebo, :is_ecco, :batch_job_id, :wks_book_id, :language_id)
      end

    end
  end
end
