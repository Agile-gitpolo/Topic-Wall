module KeywordHelper
  def normalize_keyword(kw)
    kw.to_s.downcase.gsub(/[\s_]/, '')
  end
  module_function :normalize_keyword
end 