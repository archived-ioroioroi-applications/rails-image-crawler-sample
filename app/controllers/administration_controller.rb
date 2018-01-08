class AdministrationController < ApplicationController
  def index
  end

  def show
    url = params[:imgpick_url]
    depth = params[:imgpick_depth].to_i
    height = params[:imgpick_height].to_i
    width = params[:imgpick_width].to_i
    @host = Utility::Scrap.get_host(url)
    @fqdn = Utility::Scrap.get_fqdn(url)
    @pick_imgs = []
    # pick_img_refs = pick_img_ref_nokogiri(url, depth, height, width)
    begin
      pick_img_refs = Utility::Scrap.get_img(url, depth)
    rescue => e
      error_msg = "Unknown error occured! Check logs!"
      Utility::ErrorHandling.output_task_log(e,error_msg)
      return []
    end
    pick_img_refs.each do |pick_img_ref|
      begin
        pick_img = Utility::Imageprocess.get_image(pick_img_ref, height, width)
      rescue => e
        error_msg = "Unknown error occured! Check logs!"
        Utility::ErrorHandling.output_task_log(e,error_msg)
        break
      end
      if pick_img.present?
        @pick_imgs.push({ref: pick_img_ref, columns: pick_img.columns, rows: pick_img.rows})
      else
        next
      end
    end
  end
end
