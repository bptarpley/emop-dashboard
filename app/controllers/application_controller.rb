class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
   before_filter :get_dropdown_data, { except: 'export' }
   
   def get_dropdown_data
      raw_batches = BatchJob.all()
      @job_types = JobType.all()
      @engines = OcrEngine.all()
      @fonts = Font.all()
      @print_fonts = PrintFont.all()

      @batches = []
      raw_batches.each do |batch|
         foo = {}
         foo[:id] = batch.id
         foo[:name] = batch.name
         foo[:parameters] = batch.parameters
         foo[:notes] = batch.notes
         foo[:type] = batch.job_type
         foo[:engine] = batch.ocr_engine
         foo[:font] = @fonts.index { |rec| rec.id == batch.font_id }
         #TODO
         #foo[:font] = batch.font.id
         @batches << foo
      end
   end
end
