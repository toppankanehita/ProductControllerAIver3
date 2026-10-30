class PressDataController < ApplicationController
  before_action :set_press_data, only: %i[ show edit update destroy ]

  # GET /press_data or /press_data.json
  def index
    if params["q"].present?
      @q = Job.ransack(params[:q])
      session["q"] = params["q"].respond_to?(:to_unsafe_h) ? params["q"].to_unsafe_h : params["q"]
    elsif params[:show].present? && session[:show] == "show"
      @q = Job.ransack(session[:q])
      params[:page] = session[:page]
    else
      @q = Job.ransack(session[:q])
    end
    if params[:p].present?
      unless params[:page].present?
        puts "---00---"
        params[:page] = 1
      end
      if params[:show] == "show"
        puts "---11---"
        params[:page] = params[:p]
      end
    end
    params[:show] = ""
    @q.build_grouping({ :life_eq => 1 })
    if @q.info_dateInfo03_lteq.present?

      @jobs = @q.result.page(params[:page]).per(15).order('infos.dateInfo03 ASC')
    elsif @q.info_dateInfo05_lteq.present?
      @jobs = @q.result.page(params[:page]).per(15).order('infos.dateInfo05 ASC')
    else

      @jobs = @q.result.page(params[:page]).per(15).order('id desc')
    end
    session[:show] = ""
  end

  def seisaku
    if params[:pass].present?
      session[:pass] = params[:pass]
    end
    if params["q"].present?
      @q = Job.ransack(params[:q])
      session["q"] = params["q"].respond_to?(:to_unsafe_h) ? params["q"].to_unsafe_h : params["q"]
    elsif params[:show].present? && session[:show] == "show"
      @q = Job.ransack(session[:q])
      params[:page] = session[:page]
    else
      @q = Job.ransack(session[:q])
    end
    if params[:p].present?
      unless params[:page].present?
        params[:page] = 1
      end
      if params[:show] == "show"
        params[:page] = params[:p]
      end
    end
    params[:show] = ""
    @q.build_grouping({ :life_eq => 1 })
    if @q.info_dateInfo03_lteq.present?

      @jobs = @q.result.page(params[:page]).per(15).order('infos.dateInfo03 ASC')
    elsif @q.info_dateInfo05_lteq.present?
      @jobs = @q.result.page(params[:page]).per(15).order('infos.dateInfo05 ASC')
    else

      @jobs = @q.result.page(params[:page]).per(15).order('id desc')
    end
    session[:show] = ""
  end

  def indexorg
    @press_data = PressData.all.page(params[:page]).order("start_time desc")
  end
  # GET /press_data/1 or /press_data/1.json
  def show

  end

  def job_link

    @press_data = PressData.all
    @press_data.each do |press_data|
      job = Job.find_by("den_id = ?", press_data.den_code)
      if job.present?
        press_data.job_id = job.id
        press_data.save
      end
    end
    redirect_to press_data_path
  end

  # GET /press_data/new
  def new
    @press_data = PressData.new
  end

  # GET /press_data/1/edit
  def edit
  end

  # POST /press_data or /press_data.json
  def create
    @press_data = PressData.new(press_data_params)

    respond_to do |format|
      if @press_data.save
        format.html { redirect_to press_data_url(@press_data), notice: "Press datum was successfully created." }
        format.json { render :show, status: :created, location: @press_data }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @press_data.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /press_data/1 or /press_data/1.json
  def update
    respond_to do |format|
      if @press_data.update(press_data_params)
        format.html { redirect_to press_data_url(@press_data), notice: "Press datum was successfully updated." }
        format.json { render :show, status: :ok, location: @press_data }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @press_data.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /press_data/1 or /press_data/1.json
  def destroy
    @press_data.destroy

    respond_to do |format|
      format.html { redirect_to press_data_url, notice: "Press datum was successfully destroyed." }
      format.json { head :no_content }
    end
  end
  def get_datads
    url_pre = "https://insights.plus.heidelberg.com/"
    #machine = "SM74"
    #url = "https://insights.plus.heidelberg.com/62d1e862-4def-4d03-94a6-d3a120af3a74/realtime/sheetfed-press/3d2c8623-21fd-4e66-8a03-a462ce4d4925/worksteps"

    #machine = "XL106"
    url = "https://insights.plus.heidelberg.com/62d1e862-4def-4d03-94a6-d3a120af3a74/realtime/sheetfed-press/76a616a3-1814-499c-951c-084d3bce4eab/worksteps"

    @wait_time = 3
    @timeout = 4
    # Seleniumの初期化
    wait = Selenium::WebDriver::Wait.new(:timeout => 6)
    #driver = Selenium::WebDriver.for :chrome
    options = Selenium::WebDriver::Chrome::Options.new(args: ["debuggerAddress", "127.0.0.1:9222","user-data-dir=~/Users/kanehira/PythonProjects/selenium-ruby/chromedata"])
    driver = Selenium::WebDriver.for(:chrome, options: options)

    #driver = Selenium::WebDriver.for :chrome
    driver.manage.timeouts.implicit_wait = @timeout
    driver.get(url)
    #wait.until {element.displayed?}
    #driver.find_elements(:tag_name, 'button').should have_content("20 min left to read")
    #links = wait.until{driver.find_elements(:tag_name, 'button')}
    sleep 10
    links = driver.find_elements(:tag_name, "div")
    links.each do |link|
      link.text
    end
  end
  def xget_data
    url = "https://insights.plus.heidelberg.com/62d1e862-4def-4d03-94a6-d3a120af3a74/worksteps"
    options = Selenium::WebDriver::Chrome::Options.new(args: ["user-data-dir=~/Documents/chromedata"])
    #options.add_argument("--headless=new")
    driver = Selenium::WebDriver.for(:chrome, options: options)
    driver.navigate.to url
    sleep 10
    links = driver.find_elements(tag_name: 'button')
    links.each do |v|
      sleep 2
      if  v.text.present? && v.text == "ログイン"
        v.attribute("class")
        vv = v
        vv.click
        puts "---ログイン---"
        break
      end
    end
    sleep 7
    links = driver.find_elements(tag_name: 'button')
    links.each do |v|
      sleep 2
      if  v.text.present? && v.text == "次"
        mail = driver.find_element(css: '#login_form_email')
        mail.send_keys("i-kane@to-m.com")

        sleep 7
        v.attribute("class")
        vv = v
        vv.click
        puts "---次---"
        break
      end
    end
    sleep 7
    links = driver.find_elements(tag_name: 'button')
    links.each do |v|
      sleep 2
      if  v.text.present? && v.text == "ログイン"
        pass = driver.find_element(css: '#login_form_password')
        pass.send_keys("43kane_ZAIKIO")
        sleep 7
        v.attribute("class")
        vv = v
        vv.click
        puts "---ログイン2---"
        break
      end
    end
    sleep 5
    puts "---quit---"
    driver.quit
    redirect_to press_data_path
  end
  def get_data
    url = "https://insights.plus.heidelberg.com/62d1e862-4def-4d03-94a6-d3a120af3a74/worksteps"

    @wait_time = 3
    @timeout = 4
    # Seleniumの初期化
    #options = Selenium::WebDriver::Chrome::Options.new(args: ["debuggerAddress", "127.0.0.1:9222","user-data-dir=~/Documents/chromedata"])
    options = Selenium::WebDriver::Chrome::Options.new(args: ["user-data-dir=~/Documents/chromedata"])
    #options.add_argument("--headless=new")
    driver = Selenium::WebDriver.for(:chrome, options: options)

    #$wait = Selenium::WebDriver::Wait.new(:timeout => 6)
    #driver = Selenium::WebDriver.for :chrome
    sleep 5
    driver.manage.timeouts.implicit_wait = 5
    driver.navigate.to url
    sleep 50
    # print(driver.page_source)
    # puts "--------length---------"
    # puts driver.window_handles.length
    # sleep 7
    links = driver.find_elements(tag_name: 'button')
    links.each do |v|
      sleep 2
      if  v.text.present? && v.text == "Zaikioでログイン"
        v.attribute("class")
        vv = v
        vv.click
        break
        sleep 7
      end
    end
    logins = driver.find_elements(css: '#login_form_email')
    if links.count > 0 && logins.count > 0
      if links.count > 0
        vv = ""
        links.each do |v|
          if v.text == "Zaikioでログイン"
            v.attribute("class")
            vv = v
          end
        end
        vv.click
      end
      sleep(5)

      mail = driver.find_element(css: '#login_form_email')
      mail.send_keys("i-kane@to-m.com")
      btn = driver.find_element(name: 'continue_with_email')
      btn.click
      pass = driver.find_element(css: '#login_form_password')
      pass.send_keys("43kane_ZAIKIO")

      sleep(50)
      vvv = ""
      links = session.find_elements(:class_name, "reset-tw")
      links.each do | v |
        if v.text == "ログイン"
          vvv = v
        end
      end

      vvv.click
    else
      puts 00
    end
    #sleep 20
    puts 000
    driver.get(url)
    # sleep 20
    # elements = driver.find_elements(:tag_name,'tr')
    # tr = elements[0]
    # spans = tr.find_elements(:tag_name,'span')
    # ss = ""
    # spans.each do | s |
    #   if s.text == "開始"
    #     ss = s
    #   end
    # end
    # ss.click

    sleep(30)
    get_datas = Array.new
    x = 0
    y = 0
    @elements = driver.find_elements(:tag_name,'tr')
    if @elements.count > 0
      if @elements.count > 30
        y = 340
      elsif @elements.count > 20
        y = 20
      elsif @elements.count > 10
        y = 10
      end
      @elements.each do |tr|
        if x > y then
          break
        end


        job_id = ""
        work_time = 0#作業時間
        n01 = 0 #実数
        n02 = 0 #損紙
        re_name = ""
        i = 0
        tmpArray = Array.new

        tds = tr.find_elements(:tag_name,'td')
        tds.each do |td|
          nds = td.find_elements(:tag_name,'ng-component')
          spans = td.find_elements(:tag_name,'span')
          divs = td.find_elements(:tag_name,'div')
          spans.each do |span|
            tmpArray.push(span.text)
            puts "span #{i} #{span.text}"
            i += 1
          end
          nds.each do |nd|
            tmpArray.push(nd.text)
            puts "nd #{i} #{nd.text}"
            i += 1
          end
          divs.each do |div|
            tmpArray.push(div.text)
            puts "div #{i} #{div.text}"
            i += 1
          end
        end
        puts "tmp"
        x = 0
        tmpArray.each do |tmp|
          puts "#{x} #{tmp}"
          x += 1
        end
        puts "--tmpArray[18]--"
        puts tmpArray[18]
        if tmpArray[18] == "完了" || tmpArray[23] == "完了"
          if tmpArray[0].blank? then
          elsif tmpArray[0].index("XL106") then
            re_name = "XL106"
          elsif tmpArray[0].index("XL 106") then
            re_name = "XL 106"
          elsif tmpArray[0].index("Xl106") then
            re_name = "Xl106"
          elsif tmpArray[0].index("xl106") then
            re_name = "xl106"
          elsif tmpArray[0].index("SM74") then
            re_name = "SM74"
          elsif tmpArray[0].index("SM 74") then
            re_name = "SM 74"
          elsif tmpArray[0].index("sm74") then
            re_name = "sm74"
          end
          puts "--tmpArray[0]--"
          puts tmpArray[0]
          if tmpArray[0].present? && tmpArray[0].size > 9
            den_code = tmpArray[0][0,10]
            job = Job.find_by(den_id: den_code)
            if job.present?
              job_id = job.id
            end
            if re_name.present?
              product_name = tmpArray[0].gsub(re_name,"").gsub(den_code,"")
            else
              product_name = tmpArray[0]
            end
            product_name.gsub!("　"," ")
            product_name.strip!
          else
            den_code = "-"
            product_name= tmpArray[0]
          end
          puts "--product_name--"
          puts product_name


          work_tmp = tmpArray[10].present? ? tmpArray[10].split('/') : ["-","-"]
          if work_tmp[0].present?
            warrs = work_tmp[0].split(' ')
            warrs.each do |war|
              if war.include?("h")

                work_time += war.gsub!("h","").to_i * 60
              elsif war.include?("m")
                work_time += war.gsub("m","").to_i
              end
            end
          end
          n1_tmp = tmpArray[12].present? ? tmpArray[12].split(' ') : ["-","-"]
          if n1_tmp[0].present?
            n01 = n1_tmp[0].gsub(",","")
            # n1 = n1.gsub(",")
          end
          n2_tmp = tmpArray[14].present? ? tmpArray[14].split(' ') : ["-","-"]
          if n2_tmp[0].present?
            n02 = n2_tmp[0].gsub(",","")
            # n2 = n2.gsub(",")
          end
        end
        get_data = Array.new
        if tmpArray[5].present?
          puts "--tmpArray[5])--"
          puts tmpArray
          stime = DateTime.parse(tmpArray[5]) - 9.hours
          zumi = PressData.find_by("machine = ? AND start_time = ?",tmpArray[3] , stime )


          if zumi.blank? && product_name.present?

            get_data.push(den_code) # 0

            get_data.push(product_name) # 1

            get_data.push(job_id) # 2

            get_data.push(tmpArray[5]) # 3

            get_data.push(work_time) # 4

            get_data.push(n01) # 5

            get_data.push(n02) # 6

            get_data.push(tmpArray[1]) # 7

            get_data.push(tmpArray[4]) # 8

            get_datas.push(get_data)
          end
        end
        x = x + 1
      end
      driver.close()

      get_datas.reverse!

      get_datas.each do |data|
          press_data = PressData.new
          press_data.den_code = data[0]
          press_data.product_name = data[1]
          press_data.job_id = data[2]
          press_data.start_time = data[3]
          press_data.work_time = data[4]
          press_data.n01 = data[5]
          press_data.n02 = data[6]
          press_data.paper_no = data[7]
          press_data.machine = data[8]
          press_data.save
      end
    end
    redirect_to root_path
  end
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_press_data
      @press_data = PressData.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def press_data_params
      params.require(:press_data).permit(:den_code, :product_name, :paper_no, :start_time, :work_time, :n01, :n02, :machine)
    end
end
