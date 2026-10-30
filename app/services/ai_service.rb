class AiService
  class AiUnavailableError < StandardError; end

  def self.ask_gemma(prompt)
    url = "http://127.0.0.1:11434/api/chat"

    conn = Faraday.new do |f|
      f.options.timeout = 60
    end

    response = conn.post(url) do |req|
      req.headers['Content-Type'] = 'application/json'
      req.body = {
        model: "gemma3:1b",
        messages: [{ role: "user", content: prompt }],
        stream: false
      }.to_json
    end

    if response.success?
      body = JSON.parse(response.body)
      # message -> content の順で取得
      body.dig("message", "content")
    else
      raise AiUnavailableError, "Ollama API Error: #{response.status}"
    end

  rescue Faraday::ConnectionFailed => e
    raise AiUnavailableError, "Ollamaに接続できません。#{e.message}"
  end
end