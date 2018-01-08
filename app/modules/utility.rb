require 'open-uri'
# require 'nokogiri'
# require 'rmagick'
# require './config/initializers/slack_api.rb'
# ↑ Gemでいれたライブラリのrequire は config/application.rb で担ってるから不要

module Utility
  class Scrap
    def self.get_html(uri)    # using Nokogiri
      if uri.split("//")[0] == "http:" || uri.split("//")[0] == "https:"
        charset = nil
        html = open(uri) do |f|
          charset = f.charset
          f.read
        end
        doc = Nokogiri::HTML.parse(html, charset)
        return doc
      else
        return 0
      end
    end
    def self.get_host(uri)
      if uri.split("//")[0] == "http:" || uri.split("//")[0] == "https:"
        scheme = uri.scan(%r{^(.+?)/})
        fqdn = uri.scan(%r{//(.+?)/})
        fqdn = uri.scan(%r{//(.+?)$}) if fqdn == []
        host = scheme[0][0] + "//" + fqdn[0][0]
        return host
      else
        return 0
      end
    end
    def self.get_scheme(uri)
      if uri.split("//")[0] == "http:"
        scheme = "http:"
      elsif uri.split("//")[0] == "https:"
        scheme = "https:"
      else
        return 0
      end
      return scheme
    end
    def self.get_fqdn(uri)
      fqdn = uri.scan(%r{//(.+?)/})
      if uri.split("//")[0] == "http:" || uri.split("//")[0] == "https:"
        fqdn = uri.scan(%r{//(.+?)/})
        fqdn = uri.scan(%r{//(.+?)$}) if fqdn == []
        return fqdn
      else
        return 0
      end
    end

    def self.get_img(uri, depth)    # using Nokogiri
      host = self.get_host(uri)
      scheme = self.get_scheme(uri)
      doc = self.get_html(uri)
      doc_imgs = []
      if doc == 0
        return doc_imgs
      end
      doc.css('img').each do |d|
        if d.attribute('src').value.slice(0,2) == "//"
          doc_imgs.push(scheme + d.attribute('src').value)
        elsif d.attribute('src').value.slice(0,1) == "/"
          doc_imgs.push(host + d.attribute('src').value)
        else
          doc_imgs.push(d.attribute('src').value)
        end
      end
      return doc_imgs
    end

    def self.get_img_selenium(uri, depth)    # using Nokogiri, Selenium
      host = self.get_host(uri)
      scheme = self.get_scheme(uri)
      ua = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/27.0.1453.116 Safari/537.36"
      caps = Selenium::WebDriver::Remote::Capabilities.chrome("chromeOptions" => {binary: '/usr/bin/google-chrome', args: ["--headless", "--disable-gpu", "--user-agent=#{ua}", "window-size=1280x8000"]})
      driver = Selenium::WebDriver.for :chrome, desired_capabilities: caps
      begin
        driver.navigate.to uri
        sleep 0.5
        doc = Nokogiri::HTML.parse(driver.page_source)
        doc_imgs = []
        if doc == 0
          return doc_imgs
        end
        doc.css('img').each do |d|
          if d.attribute('src').value.slice(0,2) == "//"
            doc_imgs.push(scheme + d.attribute('src').value)
          elsif d.attribute('src').value.slice(0,1) == "/"
            doc_imgs.push(host + d.attribute('src').value)
          else
            doc_imgs.push(d.attribute('src').value)
          end
        end
        return doc_imgs
      rescue => e
        logger = Logger.new('log/error.log', 3, 1024 * 1024)
        logger.error e
        return nil
      end
    end
  end

  class Imageprocess
    def self.get_image(uri, h, w)    # using RMagick
      h = 100 if h == nil
      w = 100 if w == nil
      rm_img = Magick::ImageList.new(uri)
      if rm_img.columns >= h && rm_img.rows >= w
        return rm_img
      else
        return nil
      end
    end
  end

  class SuccessHandling
    def self.output_task_log(s)
      logger = Logger.new('log/success.log', 3, 1024 * 1024)
      logger.formatter = proc do |severity, datetime, progname, msg|
        "[#{datetime}:#{progname}] #{severity}\t-- : #{msg}\n"
      end
      logger.info s
      p s
    end
  end

  class ErrorHandling
    def self.output_task_log(e,*error_msg)
      logger = Logger.new('log/error.log', 3, 1024 * 1024)
      logger.formatter = proc do |severity, datetime, progname, msg|
        "[#{datetime}:#{progname}] #{severity}\t-- : #{msg}\n"
      end
      error_msg.each do |em|
        logger.error em
      end
      logger.error e.class
      logger.error e.message
      logger.error e.backtrace.join("\n")
      p "[SystemError!] Check ErrorLog! (log/error.log)"
    end

    def self.output_message(msg)
      logger = Logger.new('log/error.log', 3, 1024 * 1024)
      logger.formatter = proc do |severity, datetime, progname, msg|
        "[#{datetime}:#{progname}] #{severity}\t-- : #{msg}\n"
      end
      logger.error msg
      p "[SystemError!] Check ErrorLog! (log/error.log)"
    end
  end



  # class SlackHandling
  #   def self.create_channel(channel_name)
  #     response = Slack.channels_create({name: channel_name})
  #     if response['ok']
  #       p message = "[Success!] Created Slack channel \"\##{channel_name}\""
  #       return message
  #     else
  #       p message = "[Failed!] Check your Slack channel. "
  #       return message
  #     end
  #   end
  #
  #   def self.leave_channel(channel_name)
  #     response = Slack.channels_leave({channel: channel_name})
  #     if response['ok']
  #       p message = "[Success!] Leaved Slack channel \"\##{channel_name}\""
  #       return message
  #     else
  #       p message = "[Failed!] Check your Slack channel. "
  #       return message
  #     end
  #   end
  #
  #   def self.check_channel
  #     response = Slack.channels_list
  #     if response['ok']
  #       response['channels'].each do |channel|
  #         p "The Channel : #{channel['name']} has ChannelID [#{channel['id']}]"
  #       end
  #       return response
  #     else
  #       p message = "[Failed!] Check your Slack channel. "
  #       return message
  #     end
  #   end
  #
  #   def self.post_message(content, user_name, channel_name)
  #     p response = Slack.chat_postMessage(text: content, username: user_name, channel: channel_name)
  #     if response['ok']
  #       p message = "[Success!] Posted message to your channel \"#{channel_name}\""
  #       return message
  #     else
  #       p message = "[Failed!] What happen!. "
  #       return message
  #     end
  #
  #   end
  # end

  class Task
    def self.lock(task_name)
      key = 0
      eval "@lock_#{task_name} = 0"
      loop do
        sleep 0.5
        eval "if @lock_#{task_name} == 1; key = 1; end;"
        break if key == 1
      end
    end

    def self.unlock(task_name)
      eval "@lock_#{task_name} = 1"
    end
  end
end
