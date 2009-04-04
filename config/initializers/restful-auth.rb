		ActiveRecord::Base.observers += [UserObserver]
		ActiveRecord::Base.instantiate_observers
