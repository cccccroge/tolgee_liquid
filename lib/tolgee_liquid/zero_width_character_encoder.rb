class ZeroWidthCharacterEncoder
  INVISIBLE_CHARACTERS = ["\u200C", "\u200D"].freeze

  def execute(text)
    bytes = text.bytes
    binary = bytes.map { |byte| to_binary_with_extra_non_join_character(byte) }.join
    to_invisible_string(binary)
  end

  private

  def to_binary_with_extra_non_join_character(byte)
    "#{byte.to_s(2).rjust(8, '0')}0"
  end

  def to_invisible_string(binary)
    binary.chars.map { |bit| INVISIBLE_CHARACTERS[bit.to_i].encode('utf-8') }.join
  end
end
