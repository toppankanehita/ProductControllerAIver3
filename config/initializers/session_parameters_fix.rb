# frozen_string_literal: true

# Rails 8 / Rack 3 では ActionController::Parameters に @logging_context 等の
# シリアライズ不可能な IO/StringIO オブジェクトが含まれる場合があり、
# ActiveRecord::SessionStore (MarshalSerializer) 経由で session に格納されると
# TypeError: can't dump IO / no _dump_data is defined for class StringIO が発生する。
# これを防ぐため、Marshal 時に安全な Hash 構造のみをダンプ/ロードできるようにする。

ActiveSupport.on_load(:action_controller) do
  class ActionController::Parameters
    def marshal_dump
      to_unsafe_h
    end

    def marshal_load(hash)
      @parameters = hash.respond_to?(:with_indifferent_access) ? hash.with_indifferent_access : ActiveSupport::HashWithIndifferentAccess.new(hash)
      @permitted = false
    end
  end
end
