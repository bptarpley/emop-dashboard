require 'rails_helper'

RSpec.describe ResultsController, :type => :controller do

  let(:valid_session) { {} }

  describe "GET show" do
    before(:each) do
      @print_font = create(:print_font)
      @work = create(:work, print_font: @print_font)
      @page = @work.pages.first
      @batch_job = create(:batch_job)
      @job_queue = create(:job_queue, page: @page, work: @work, batch_job: @batch_job, status: JobStatus.done)
      @page_result = create(:page_result, page: @page, batch_job: @batch_job)
      @postproc_page = create(:postproc_page, page: @page, batch_job: @batch_job)

      @params = {
        work: @work.id,
        batch: @batch_job.id,
      }
    end

    it "should respond successfully" do
      get :show, @params

      expect(response).to be_success
    end

    it "should set instance variables" do
      get :show, @params

      expect(assigns(:work)).to eq(@work)
      expect(assigns(:batch_job)).to eq(@batch_job)
    end

    it 'assigns stats' do
      get :show, @params
      expect(assigns(:stats).size).to eq(5)
      expect(assigns(:stats)).to include('total')
      expect(assigns(:stats)).to include('ignored')
      expect(assigns(:stats)).to include('correct')
      expect(assigns(:stats)).to include('corrected')
      expect(assigns(:stats)).to include('unchanged')
    end
  end

 describe "GET page_text" do
    before(:each) do
      @print_font = create(:print_font)
      @work = create(:work, print_font: @print_font)
      @page = @work.pages.first
      @batch_job = create(:batch_job)
      @job_queue = create(:job_queue, page: @page, work: @work, batch_job: @batch_job, status: JobStatus.done)
      @page_result = create(:page_result, page: @page, batch_job: @batch_job)

      @params = {
        id: @page_result.id,
      }
      # Mock directory storing OCR output
      @emop_path_prefix = Dir.mktmpdir
      allow(Rails.application.secrets).to receive(:emop_path_prefix) { @emop_path_prefix }
      # Mock text output
      FileUtils.mkdir_p(File.dirname(@page_result.local_text_path))
      File.open(@page_result.local_text_path, "w") {|f| f.write "ocr-text-output" }
    end

    after(:each) do
      FileUtils.rm_rf(@emop_path_prefix)
    end

    it "should respond successfully" do
      get :page_text, @params

      expect(response).to be_success
    end

    it "should respond with page result information" do
      get :page_text, @params

      expect(json['page']).to eq(@page.pg_ref_number)
      expect(json['content']).to eq('ocr-text-output')
    end

    it "should respond with page result information for IDHMC page" do
      FileUtils.mkdir_p(File.dirname(@page_result.local_idhmc_text_path))
      File.open(@page_result.local_idhmc_text_path, "w") {|f| f.write "ocr-idhmc-text-output" }

      get :page_text, @params

      expect(json['page']).to eq(@page.pg_ref_number)
      expect(json['content']).to eq('ocr-idhmc-text-output')
    end

    it "should send data" do
      @params[:download] = true

      get :page_text, @params

      expect(response.headers['Content-Disposition']).to eq("attachment; filename=\"#{File.basename(@page_result.ocr_text_path)}\"")
      expect(response.headers['Content-Type']).to eq('text/plain')
    end

    context 'when the requested file does not exist' do
      before(:each) do
        FileUtils.rm_rf(@emop_path_prefix)
      end

      it "should alert when file not found" do
        get :page_text, @params
        expect(response).to be_success
        expect(json['content']).to eq('File not found!')
      end

      it "should not allow download" do
        @params[:download] = true
        get :page_text, @params
        expect(response).to be_success
        expect(json['content']).to eq('File not found!')
      end
    end
  end

 describe "GET page_hocr" do
    before(:each) do
      @print_font = create(:print_font)
      @work = create(:work, print_font: @print_font)
      @page = @work.pages.first
      @batch_job = create(:batch_job)
      @job_queue = create(:job_queue, page: @page, work: @work, batch_job: @batch_job, status: JobStatus.done)
      @page_result = create(:page_result, page: @page, batch_job: @batch_job)

      @params = {
        id: @page_result.id,
      }
      # Mock directory storing OCR output
      @emop_path_prefix = Dir.mktmpdir
      allow(Rails.application.secrets).to receive(:emop_path_prefix) { @emop_path_prefix }
      # Mock xml output
      FileUtils.mkdir_p(File.dirname(@page_result.local_xml_path))
      File.open(@page_result.local_xml_path, "w") {|f| f.write "ocr-xml-output" }
    end

    after(:each) do
      FileUtils.rm_rf(@emop_path_prefix)
    end

    it "should respond successfully" do
      get :page_hocr, @params

      expect(response).to be_success
    end

    it "should respond with page result information" do
      get :page_hocr, @params

      expect(json['page']).to eq(@page.pg_ref_number)
      expect(json['content']).to eq('ocr-xml-output')
    end

    it "should respond with page result information for IDHMC page" do
      FileUtils.mkdir_p(File.dirname(@page_result.local_idhmc_xml_path))
      File.open(@page_result.local_idhmc_xml_path, "w") {|f| f.write "ocr-idhmc-xml-output" }

      get :page_hocr, @params

      expect(json['page']).to eq(@page.pg_ref_number)
      expect(json['content']).to eq('ocr-idhmc-xml-output')
    end

    it "should send data" do
      @params[:download] = true

      get :page_hocr, @params

      expect(response.headers['Content-Disposition']).to eq("attachment; filename=\"#{File.basename(@page_result.ocr_xml_path)}\"")
      expect(response.headers['Content-Type']).to eq('text/xml')
    end

    context 'when the requested file does not exist' do
      before(:each) do
        FileUtils.rm_rf(@emop_path_prefix)
      end

      it "should alert when file not found" do
        get :page_hocr, @params
        expect(response).to be_success
        expect(json['content']).to eq('File not found!')
      end

      it "should not allow download" do
        @params[:download] = true
        get :page_hocr, @params
        expect(response).to be_success
        expect(json['content']).to eq('File not found!')
      end
    end
  end

  describe "GET page_image" do
    before(:each) do
      @print_font = create(:print_font)
      @work = create(:work, print_font: @print_font)
      @page = @work.pages.first

      @params = {
        work: @work.id,
        num: @page.pg_ref_number,
      }
      # Mock directory storing OCR output
      @emop_path_prefix = Dir.mktmpdir
      allow(Rails.application.secrets).to receive(:emop_path_prefix) { @emop_path_prefix }
      image_file = Rails.root.join("spec/fixtures/files/phototest.tif")
      # Set page image path as /phototest.tif
      pg_image_path = File.join('/', File.basename(image_file))
      @page.update!(pg_image_path: pg_image_path)
      # Copy the fixture to mocked directory
      FileUtils.cp(image_file, File.join(@emop_path_prefix, pg_image_path))

      # Load converted fixture into tests
      require 'RMagick'
      @png_image = Magick::Image.read(Rails.root.join('spec/fixtures/files/phototest.png')).first

      # Mock referer URL to test if redirect occurs
      @referer = "http://localhost/results?work=#{@work.id}"
      allow(controller.request).to receive(:referer).and_return(@referer)
    end

    after(:each) do
      FileUtils.rm_rf(@emop_path_prefix)
    end

    it "should respond successfully" do
      get :page_image, @params
      expect(response).to be_success
    end

    it "should have valid headers" do
      get :page_image, @params
      expect(response.headers['Content-Type']).to eq('image/png')
    end

    it "should send image" do
      get :page_image, @params
      sent_image = Magick::Image.from_blob(response.body).first
      expect(sent_image.export_pixels.join).to be_same_md5sum(@png_image.export_pixels.join)
    end

    it "should redirect when file does not exist" do
      FileUtils.rm_rf(@emop_path_prefix)
      get :page_image, @params
      expect(subject).to redirect_to(@referer)
    end
  end

  describe "GET page_error" do
    before(:each) do
      @work = create(:work)
      @page = @work.pages.first
      @batch_job = create(:batch_job)
      @job_queue = create(:job_queue, page: @page, work: @work, batch_job: @batch_job, status: JobStatus.failed, results: "ERROR")

      @params = {
        page: @page.id,
        batch: @batch_job.id,
      }
    end

    it "should respond successfully" do
      get :page_error, @params

      expect(response).to be_success
    end

    it "should respond with a jobs results" do
      get :page_error, @params

      expect(json).to match(
        'page' => @page.pg_ref_number,
        'error' => @job_queue.results,
      )
    end
  end

  describe "POST reschedule" do
    before(:each) do
      @batch_job = create(:batch_job)
      @work = create(:work)
      @page = create(:page, work: @work)
      @job_queue = create(:job_queue, batch_job: @batch_job, page: @page, work: @work, status: JobStatus.failed, proc_id: '00001', results: 'error')
      @page_result = create(:page_result, batch_job: @batch_job, page: @page)
      @postproc_page = create(:postproc_page, batch_job: @batch_job, page: @page)
      @params = {
        pages: [@page.id],
        batch: @batch_job.id,
      }
    end

    it "should respond successfully" do
      post :reschedule, @params

      expect(response).to be_success
    end

    it "should reschedule a batch job" do
      post :reschedule, @params

      expect { PageResult.find(@page_result.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect { PostprocPage.find(@postproc_page.id) }.to raise_error(ActiveRecord::RecordNotFound)
      job_queue = JobQueue.find(@job_queue.id)
      expect(job_queue.status).to eq(JobStatus.not_started)
      expect(job_queue.proc_id).to be_nil
      expect(job_queue.results).to be_nil
    end
  end

  describe "POST create_batch" do
    before(:each) do
      @job_type = JobType.find_by(name: 'OCR')
      @ocr_engine = OcrEngine.find_by(name: 'Tesseract')
      @font = create(:font)
      @work = create(:work)
      @pages = create_list(:page, 2, work: @work)
      @page_ids = @pages.map(&:id)

      @params = {
        name: 'TEST',
        type_id: @job_type.id,
        engine_id: @ocr_engine.id,
        font_id: @font.id,
        #Can't use params in params
        #params: '',
        notes: '',
        json: {pages: @page_ids, work: @work.id}.to_json,
      }
    end

    it "should respond successfully" do
      post :create_batch, @params

      expect(response).to be_success
      expect(response.body).to_not be_nil
    end

    it "should respond with batch job ID" do
      post :create_batch, @params

      batch_job = BatchJob.find_by(name: @params[:name])
      expect(response.body).to eq(batch_job.id.to_s)
    end

    it "should create batch of selected pages" do
      post :create_batch, @params

      batch_job = BatchJob.find_by(name: @params[:name])
      expect(batch_job.job_type).to eq(@job_type)
      expect(batch_job.ocr_engine).to eq(@ocr_engine)
      expect(batch_job.font).to eq(@font)
    end

    it "should create job queue for each page" do
      post :create_batch, @params

      job_queues = JobQueue.all
      batch_job = BatchJob.find_by(name: @params[:name])
      expect(job_queues.size).to eq(@pages.count)
      job_queues.each do |job_queue|
        expect(job_queue.batch_job).to eq(batch_job)
      end
    end
  end
end
