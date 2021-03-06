module Api
  module V1
    class JobQueuesController < V1::BaseController

      api :GET, '/job_queues', 'List job queues'
      param_group :pagination, V1::BaseController
      param :job_status_id, Integer, desc: 'Job status ID'
      param :batch_id, Integer, desc: 'Batch job ID'
      param :work_id, Integer, desc: 'Work ID'
      def index
        super
      end

      api :GET, '/job_queues/:id', 'Show a job queue'
      param :id, Integer, desc: "Job queue ID", required: true
      def show
        super
      end

      api :GET, '/job_queues/count', 'Count of job queues'
      param :job_status_id, Integer, desc: 'Job status ID'
      param :batch_id, Integer, desc: 'Batch job ID'
      param :work_id, Integer, desc: 'Work ID'
      def count
        @count = JobQueue.where(query_params).count
        respond_with @count
      end

      api :PUT, '/job_queues/reserve', 'Reserve job queues'
      param :job_queue, Hash, required: true do
        param :num_pages, Integer, desc: 'Number of pages to reserve', required: true
        param :batch_id, Integer, desc: 'Batch job ID'
        param :work_id, Integer, desc: 'Work ID'
      end
      def reserve
        @num_pages = job_queue_params[:num_pages].to_i
        @proc_id = JobQueue.generate_proc_id
        processing_id = JobStatus.processing.id
        filter = job_queue_params.except(:num_pages)

        JobQueue.unreserved.where(filter).limit(@num_pages)
          .update_all(proc_id: @proc_id, job_status_id: processing_id)

        @job_queues = JobQueue.where(filter).where(proc_id: @proc_id, job_status_id: processing_id)
        respond_with @job_queues
      end

      api :PUT, '/job_queues/set_job_id', 'Set JobQueue job ID'
      param :job_queue, Hash, required: true do
        param :proc_id, String, desc: 'ProcID', required: true
        param :job_id, String, desc: 'Cluster JobID', required: true
      end
      def set_job_id
        @job_queues = JobQueue.where(proc_id: set_job_id_params[:proc_id])
        if @job_queues.update_all(job_id: set_job_id_params[:job_id])
          render json: nil, status: :ok
        else
          render json: nil, status: :unprocessable_entity
        end
      end

      private

      def job_queue_params
        params.require(:job_queue).permit(:num_pages, :batch_id, :work_id)
      end

      def set_job_id_params
        params.require(:job_queue).permit(:proc_id, :job_id)
      end

      def query_params
        params.permit(:job_status_id, :num_pages, :proc_id, :batch_id, :work_id)
      end

    end
  end
end
