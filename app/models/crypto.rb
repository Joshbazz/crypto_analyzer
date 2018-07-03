class Crypto < ApplicationRecord
	def new
		@crypto = Crpyto.new

		respond_to do |format|
			format.html
			format.json { render :json => @post }
		end
	end
end
