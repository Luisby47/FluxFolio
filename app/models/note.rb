# Note model represents notes attached to portfolios or investments
# It uses polymorphic association to allow attaching notes to different types of objects
class Note < ApplicationRecord
  # Polymorphic relationship - can belong to different types of objects
  # (currently supports Portfolio and Investment)
  belongs_to :notable, polymorphic: true

  # Validations
  validates :content, presence: true
  # Importance is a 1-5 scale where 1 is most important and 5 is least important
  validates :importance, presence: true,
                        numericality: { only_integer: true,
                                      greater_than_or_equal_to: 1,
                                      less_than_or_equal_to: 5 }

  # Callbacks
  before_validation :set_default_importance

  private

    # Set default importance to 5 (lowest) if not specified
    def set_default_importance
      self.importance ||= 5
    end
end
