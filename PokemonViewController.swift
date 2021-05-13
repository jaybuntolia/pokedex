import UIKit

class PokemonViewController: UIViewController {
    var url: String!
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var numberLabel: UILabel!
    @IBOutlet var type1Label: UILabel!
    @IBOutlet var type2Label: UILabel!
    @IBOutlet var catchButton: UIButton!
    @IBOutlet var Image: UIImageView!
    @IBOutlet var descriptionLabel: UILabel!
    
    var currentDescURL: String = "https://pokeapi.co/api/v2/pokemon-species/1"
    var n = UserDefaults.standard.object(forKey: "catches") as! [String : Bool]
    var name = ""
    var catched = false
    
    func capitalize(text: String) -> String {
        return text.prefix(1).uppercased() + text.dropFirst()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        nameLabel.text = ""
        numberLabel.text = ""
        type1Label.text = ""
        type2Label.text = ""

        loadPokemon()
        showPokemonDescription()
    }
    
    func loadPokemon() {
        URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, error) in
            guard let data = data else {
                return
            }

            do {
                let result = try JSONDecoder().decode(PokemonResult.self, from: data)
                DispatchQueue.main.async {
                    self.navigationItem.title = self.capitalize(text: result.name)
                    self.nameLabel.text = self.capitalize(text: result.name)
                    self.numberLabel.text = String(format: "#%03d", result.id)
                    self.catched = self.n[result.name]!
                    self.name = result.name
                    
                    if self.catched == true {
                        self.catchButton.setTitle("Release", for: .normal)
                    }

                    for typeEntry in result.types {
                        if typeEntry.slot == 1 {
                            self.type1Label.text = typeEntry.type.name
                        }
                        else if typeEntry.slot == 2 {
                            self.type2Label.text = typeEntry.type.name
                        }
                    }
                    
                    guard let imageURL = URL(string: result.sprites.front_default) else { return }
                    if let data = try? Data(contentsOf: imageURL) {
                        self.Image.image = UIImage(data: data)
                    }
                    self.currentDescURL = result.species.url
                    print(self.currentDescURL)
                }
            }
            catch let error {
                print(error)
            }
        }.resume()
    }
    
    func showPokemonDescription() {
        guard let pokemonDescriptionURL = URL(string: currentDescURL) else { return }
        URLSession.shared.dataTask(with: pokemonDescriptionURL) { (data, _, error) in
            guard let data = data else { return }
            do {
                let result = try JSONDecoder().decode(PokemonDescription.self, from: data)
                DispatchQueue.main.async {
                    // Check and get first pokemon description in English
                    for index in 0..<result.flavor_text_entries.count {
                        if result.flavor_text_entries[index].language.name == "en" {
                            self.descriptionLabel.text = result.flavor_text_entries[index].flavor_text
                        }
                    }
                }
            } catch let error { print(error) }
        }.resume()
    }
    

    @IBAction func toggleCatch() {
        if catched == false {
            catchButton.setTitle("Release", for: .normal)
            catched = true
        } else {
            catchButton.setTitle("Catch", for: .normal)
            catched = false
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
            
        n.updateValue(catched, forKey: name)
        UserDefaults.standard.set(n, forKey: "catches")
    }
    
}

