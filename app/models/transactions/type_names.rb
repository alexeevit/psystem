module Transactions
  module TypeNames
    TYPES = {
      authorize: Transactions::Authorize,
      capture: Transactions::Capture,
      refund: Transactions::Refund,
      void: Transactions::Void
    }.freeze

    TYPE_NAMES = TYPES.to_a.map(&:reverse).to_h.freeze
  end
end
