//
//  ViewController.swift
//  Bluebonnet
//
//  Created by kitagawa on 07/02/2015.
//  Copyright (c) 07/02/2015 kitagawa. All rights reserved.
//

import UIKit
import SwiftTask

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        loadUser("yatatsu")
        loadRepos("yatatsu")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadUser(userName: String) {
        let task = GitHubAPI.requestTask(GitHubAPI.GetUserProfile(userName: userName))
        task
            .progress { (oldProgress, newProgress) in
                print(newProgress.bytesWritten)
                print(newProgress.totalBytesWritten)
                return
            }
            .success { (user: User) -> Void in
                print("\n")
                print(user.name)
                return
            }
            .failure { (errorResult, isCancelled) -> Void in
                print(errorResult?.error.description)
                return
        }
        print("start\n")
    }
    
    func loadRepos(userName: String) {
        let task = GitHubAPI.requestTask(GitHubAPI.GetUserRepos(userName: userName, sort: .Pushed))
        task
            .success { (repos: Repos) -> Void in
                repos.repos.map { (repo: Repo) -> Void in
                    print("\n")
                    print("\(repo.name)\n\(repo.description)")
                }
                return
            }
            .failure { (errorResult, isCancelled) -> Void in
                print(errorResult?.error.description)
                return
        }
    }

}

