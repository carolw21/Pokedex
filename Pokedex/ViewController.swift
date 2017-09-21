//
//  ViewController.swift
//  Pokedex
//
//  Created by SAMEER SURESH on 9/25/16.
//  Copyright © 2016 trainingprogram. All rights reserved.
//

// The Starting Screen that has the search bar

// TODO: Filter search results based on mode.

import UIKit

class ViewController: UIViewController {
    var searchBar: UISearchBar!
    var searchButton: UIButton!
    
    var backgroundImage: UIImageView!
    var modeButton: UIButton!
    var pdb: PDB = PDB()
    var pokemonToPass: Pokemon?
    var pickerView: UIPickerView = UIPickerView() //pickervew to select a mode
    var modeArray: [String] = ["Name", "Number", "Type", "Minimum Attack Points", "Minimum Defense Points", "Minimum Health Points"]
    var selectedMode: String!
    var typesCollectionView: UICollectionView!
    var typeImages = [UIImage(named: "bug"), UIImage(named: "dark"), UIImage(named: "dragon"), UIImage(named: "electric"), UIImage(named: "fairy"), UIImage(named: "fighting"), UIImage(named: "fire"), UIImage(named: "flying"), UIImage(named: "ghost"), UIImage(named: "grass"), UIImage(named: "ground"), UIImage(named: "ice"), UIImage(named: "normal"), UIImage(named: "poison"), UIImage(named: "psychic"), UIImage(named: "rock"), UIImage(named: "steel"), UIImage(named: "water")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupUI();
    }

    func setupUI() {
        let VFH = view.frame.height
        let VFW = view.frame.width
        
        backgroundImage = UIImageView(frame: view.frame)
        backgroundImage.image = UIImage(named: "background")
        backgroundImage.contentMode = .scaleAspectFill
        view.addSubview(backgroundImage)
        
        setupTypesCollectionView()
        view.addSubview(typesCollectionView)

        setupSearchBar()
        view.addSubview(searchBar)
        
        
        // Creating the button to search
        searchButton = UIButton(frame: CGRect(x: VFW * 0.9, y: VFH * 0.3, width: 40, height: 40))
        searchButton.backgroundColor = UIColor.blue
        searchButton.setTitle("Go", for: .normal)
        searchButton.addTarget(self, action: #selector(searchButtonPressed), for: .touchUpInside)
        view.addSubview(searchButton)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        modeButton = UIButton(frame: CGRect(x: VFW/2 - 150, y: searchBar.frame.maxY + 20, width: 300, height: 60))
        // Hardcoded the default mode to be Name
        modeButton.setTitle("Name", for: .normal)
        selectedMode = "Name"
        modeButton.setTitleColor(UIColor.white, for: .normal)
        modeButton.backgroundColor = UIColor.red
        modeButton.layer.cornerRadius = 8
        modeButton.addTarget(self, action: #selector(togglePickerView), for: .touchUpInside)
        view.addSubview(modeButton)
        
        setupPickerView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func dismissKeyboard() {
        // Makes the keyboard go back down
        self.searchBar.endEditing(true)
    }
    
    func togglePickerView() {
        if !self.pickerView.isDescendant(of: view) {
            view.addSubview(self.pickerView)
            view.bringSubview(toFront: self.pickerView)
        }
        else {
            self.pickerView.removeFromSuperview()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToSearchVC" {
            let searchVC = segue.destination as! SearchResultsViewController
            searchVC.pokemonList = [] //pass in search results array eventually
        }
        if segue.identifier == "segueToPokemonVC" {
            let pokemonVC = segue.destination as! PokemonViewController
            pokemonVC.pokemon = pokemonToPass
        }
    }
    
    func searchButtonPressed() {
        searchBarSearchButtonClicked(searchBar)
    }
    
    func changeButtonMode() {
        modeButton.setTitle(selectedMode, for: .normal)
        if selectedMode == "Type" {
            searchBarToTypeSelector()
        } else if searchBar.isHidden {
            typeSelectorToSearchBar()
        }
        self.pickerView.removeFromSuperview()
    }
    
    func searchBarToTypeSelector() {
        searchBar.isHidden = true
        typesCollectionView.isHidden = false
    }
    
    func typeSelectorToSearchBar() {
        searchBar.isHidden = false
        typesCollectionView.isHidden = true
    }
    
    func setupPickerView() {
        self.pickerView.dataSource = self
        self.pickerView.delegate = self
        self.pickerView.frame = CGRect(x: 0, y: modeButton.frame.maxY + 5, width: view.frame.width, height: 200)
        self.pickerView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.7)
    }
    
    func setupSearchBar() {
        searchBar = UISearchBar(frame: CGRect(x: view.frame.width * 0.1,
                                              y: view.frame.height * 0.3,
                                              width: view.frame.width * 0.8,
                                              height: 100))
        searchBar.placeholder = "Search Pokédex..."
        searchBar.delegate = self
        searchBar.isHidden = false
    }
    
    func setupTypesCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        typesCollectionView = UICollectionView(frame: CGRect(x: view.frame.width * 0.1,
                                                             y: view.frame.height * 0.25,
                                                             width: view.frame.width * 0.8,
                                                             height: 150), collectionViewLayout: layout)
        typesCollectionView.backgroundColor = UIColor(white: 1, alpha: 0)
        typesCollectionView.register(TypeCollectionViewCell.self, forCellWithReuseIdentifier: "typeCell")
        typesCollectionView.delegate = self
        typesCollectionView.dataSource = self
        typesCollectionView.isHidden = true
    }
}

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    // functions for collection view of types
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return typeImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "typeCell", for: indexPath) as! TypeCollectionViewCell
        cell.awakeFromNib()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let typeCell = cell as! TypeCollectionViewCell
        typeCell.typeImageView.image = typeImages[indexPath.row]
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 40, height: 20)
    }
    
    // functions for picker view
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return modeArray.count
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var pickerLabel: UILabel = UILabel()
        pickerLabel.text = modeArray[row]
        pickerLabel.textColor = UIColor.black
        pickerLabel.textAlignment = .center
        pickerLabel.sizeToFit()
        pickerLabel.numberOfLines = 0
        
        return pickerLabel
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedMode = modeArray[row]
        changeButtonMode()
        //call segue eventually
    }

    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 36.0
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 36.0
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if selectedMode == "Name" {
            let result: Pokemon? = pdb.searchName(name: searchBar.text!)
            if let x = result {
                pokemonToPass = x
                performSegue(withIdentifier: "segueToPokemonVC", sender: self)
            } else {
                print("search pokemon failed!")
            }
        }
        if selectedMode == "Number" {
            var result: Pokemon?
            if let number = Int(searchBar.text!) {
                result = pdb.searchNumber(number: number)
                if let x = result {
                    pokemonToPass = x
                    performSegue(withIdentifier: "segueToPokemonVC", sender: self)
                    return
                }
            }
            print("error happened")
        }
        if selectedMode == "Minimum Attack Points" {
            print("NOT IMPLEMENTED")
        }
        if selectedMode == "Minimum Defense Points" {
            print("NOT IMPLEMENTED")
        }
        if selectedMode == "Minimum Health Points" {
            print("NOT IMPLEMENTED")
        }
    }
}
