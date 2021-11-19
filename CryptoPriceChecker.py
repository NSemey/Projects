from bs4 import BeautifulSoup   		# line of code to access beautifulsoup libararies and requests libararies.
import requests					# and the requests libararies.

url = "https://coinmarketcap.com/"  		#url we are scrapping from
result = requests.get(url).text   		#will be the results we place in a empty array later
doc = BeautifulSoup(result, "html.parser") 	#the results of the scrap being parsed

tbody = doc.tbody  				#.tbody is used for getting the elements for table row.
trs = tbody.contents 				#Get the whole content from the tbody

prices = {}  					#empty array we will fill with results at the end

for tr in trs[:10]:  				# for loop to go through elements and grab the name and price
	name, price = tr.contents[2:4]  	#clearifing where the name and price is located
	fixed_name = name.p.string  		#for each turn in the loop it will get a name and transform it into a string
	fixed_price = price.a.string 	 	#also for each turn in the loop it will get the price for each coin

	prices[fixed_name] = fixed_price  	#then we make it so each turn in the loop that the coins name and price is matched together.

print(prices) 					#after the for loop runs 10 times to where we set it, it will then print the names and prices off from the prices variable
