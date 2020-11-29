import Foundation

protocol CoinManagerDelegate {
    func didUpdatePrice(price: String, currency: String)
    func didFailWithError(error: Error)
}

struct CoinManager {
    var delegate: CoinManagerDelegate?;
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "7CE0A545-2DB0-4964-A9A8-1C2A327B6B01"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    
    func getCoinPrice(for currency: String) {
        // 1- create url
        let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        if let url = URL(string: urlString) {
            // 2- create url session
            let session = URLSession(configuration: .default)
            
            // 3- give the session a task
            let task = session.dataTask(with: url) {(data, response, error) in
                if error != nil {
                    print(error ?? "")
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    //
                    if let bitcoinPrice = self.parseJson(safeData) {
                        let priceString = String(format: "%.2f", bitcoinPrice)
                        self.delegate? .didUpdatePrice(price: priceString, currency: currency) // make your delegate to end this task, you Never mind the details
                    }
                    
                }
                
            }
            // 4- start task
            task.resume()
        }
        
    }
    
    func parseJson(_ data: Data) -> Double? {
        let decoder = JSONDecoder()
        do {
            //try to decode the data using the CoinData structure
            let decodedData = try decoder.decode(CoinData.self, from: data)
            
            //Get the last property from the decoded data.
            let lastPrice = decodedData.rate
            print(lastPrice)
            return lastPrice
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
