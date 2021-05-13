import UIKit

class PokemonListViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet var searchBar: UISearchBar!
    
    var pokemon: [PokemonListResult] = []
    var filteredData: [PokemonListResult] = []
    var pokeSearch = false
    let defaults = UserDefaults.standard
    
    func capitalize(text: String) -> String {
        return text.prefix(1).uppercased() + text.dropFirst()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=151") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                return
            }
            
            do {
                let entries = try JSONDecoder().decode(PokemonListResults.self, from: data)
                self.pokemon = entries.results
                self.filteredData = self.pokemon
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            catch let error {
                print(error)
            }
        }.resume()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if pokeSearch {
            return filteredData.count
        } else {
            return pokemon.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PokemonCell", for: indexPath)
        if pokeSearch {
            cell.textLabel?.text = capitalize(text: filteredData[indexPath.row].name)
        } else {
            cell.textLabel?.text = capitalize(text: pokemon[indexPath.row].name)
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if UserDefaults.standard.bool(forKey: "on") == false{
            defaults.set(true, forKey: "on")
            var catches: [String : Bool] = [:]
            for poke in pokemon {
                catches.updateValue(false, forKey: poke.name)
            }
            defaults.set(catches, forKey: "catches")
        }
        if segue.identifier == "ShowPokemonSegue",
                let destination = segue.destination as? PokemonViewController,
                let index = tableView.indexPathForSelectedRow?.row {
            destination.url = pokemon[index].url
        }
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == " " || searchBar.text == nil {
            pokeSearch = false
            tableView.reloadData()
        } else {
            
            let lower = searchBar.text!.lowercased()
            
            filteredData = pokemon.filter({$0.name.range(of: lower) != nil})
            //filteredData = pokemon.filter({pokemon -> Bool in
               // pokemon.name.contains(searchText)
            }
            pokeSearch = true
                       
            tableView.reloadData()
            
        }
    }



