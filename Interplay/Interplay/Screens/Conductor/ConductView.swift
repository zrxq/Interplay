//
//  ConductView.swift
//  Interplay
//
//  Created by Zoreslav Khimich on 1/20/18.
//  Copyright © 2018 The Jam Gym. All rights reserved.
//

import UIKit

extension ConductViewController {
    class ConductView: UIView {
        let musiciansLayout: UICollectionViewFlowLayout = {
            let flowLayout = UICollectionViewFlowLayout()
            flowLayout.minimumLineSpacing = Style.Conductor.MusiciansCollectionView.minimumLineSpacing
            flowLayout.minimumInteritemSpacing = Style.Conductor.MusiciansCollectionView.minimumInteritemSpacing
            flowLayout.sectionInset = Style.Conductor.MusiciansCollectionView.sectionInset
            return flowLayout
        }()
        
        let musiciansCollectionView: UICollectionView

        override init(frame: CGRect) {
            musiciansCollectionView = UICollectionView(frame: .zero, collectionViewLayout: musiciansLayout)
            super.init(frame: frame)
            
            musiciansCollectionView.transform = CGAffineTransform(scaleX: 1, y: -1)
            self.addSubview(musiciansCollectionView)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("Not implemented.")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            let numberOfColumns = Int(self.bounds.width / Style.Conductor.MusiciansCollectionView.minimumColumnWidth)
            let contentWidth = self.bounds.width - musiciansCollectionView.contentInset.left - musiciansCollectionView.contentInset.right
            let sectionWidth = contentWidth - musiciansLayout.sectionInset.left - musiciansLayout.sectionInset.right
            let columnWidth = (sectionWidth - musiciansLayout.minimumInteritemSpacing * CGFloat(numberOfColumns - 1)) / CGFloat(numberOfColumns)
            musiciansLayout.itemSize = CGSize(width: columnWidth, height:Style.Conductor.MusiciansCollectionView.cellHeight)
            
            musiciansCollectionView.frame = self.bounds
        }
    }
}

