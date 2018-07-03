Things to checkout:
Body partial in views
In body code, table has methods with already defined ticker
EX:
<tbody>
            <tr>
              <td><%= Coinmarketcap.coin('bitcoin')[0]["name"] %></td>
              <td><%= Coinmarketcap.percent_marketcap('bitcoin') %></td>
Want to be able to have the area where 'bitcoin' is called be an interpolation, so when a user calls a ticker from the view, their input can be registered and then inserted into the method
EX: From vendor/gems/coinmarketcap/lib/coinmarketcap.rb
 def self.coin(id, currency = 'USD')
    HTTParty.get("https://api.coinmarketcap.com/v1/ticker/#{id}/?convert=#{currency}")
  end
id and currency are inserted into the get call on coinmarketcap api using #{}
want to be able to connect the input from a user (as a ticker), translate into the method parameter, in order to interpolate into the get request so the code for the view can look like this:
         <tr>
              <td><%= Coinmarketcap.coin(#{USERINPUT})[0]["name"] %></td>
              <td><%= Coinmarketcap.percent_marketcap(#{USERINPUT}) %></td>
so the user can directly call the methods from the api
 crypto_analyzer
