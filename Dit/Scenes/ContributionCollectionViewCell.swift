//
//  ContributionCollectionViewCell.swift
//  Dit
//
//  Created by 강태준 on 2022/09/08.
//

import UIKit
import SnapKit


final class ContributionCollectionViewCell: UICollectionViewCell {
    private lazy var colorView: UIView = {
        let view = UIView()
        view.backgroundColor = .green
        view.layer.cornerRadius = 10
        
        return view
    }()
    
    func setup() {
        addSubview(colorView)
        colorView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalToSuperview().inset(5)
        }
    }
}
