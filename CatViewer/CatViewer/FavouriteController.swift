//
//  FavouriteController.swift
//  CatViewer
//
//  Created by José Servet Font on 7/2/15.
//  Copyright (c) 2015 ByBDesigns. All rights reserved.
//

import UIKit

class FavouriteController: UITableViewController {

	var fetchedResultsController: NSFetchedResultsController? = nil
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
		
		if let mainContext = AppDelegate.mainContext()
		{
			let model = mainContext.managedObjectModel()
			if let favouriteFetchRequest = model.fetchRequestFromTemplateWithName("Favourites", substitutionVariables: [ NSObject : AnyObject ]() )
			{
				favouriteFetchRequest.sortDescriptors = [ NSSortDescriptor(key: "date", ascending: false) ]
				
				self.fetchedResultsController = NSFetchedResultsController(fetchRequest: favouriteFetchRequest, managedObjectContext: mainContext, sectionNameKeyPath: nil, cacheName: nil)
				self.fetchedResultsController?.delegate = self
				self.fetchedResultsController?.performFetch(nil)
			}
		}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension FavouriteController
{
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return self.fetchedResultsController?.sections?.count ?? 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        if let sectionInfo = self.fetchedResultsController?.sections?[section] as? NSFetchedResultsSectionInfo
		{
			return sectionInfo.numberOfObjects
		}
		
		return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("favouriteCell", forIndexPath: indexPath) as FavouriteCell

        // Configure the cell...
		cell.favourite = self.fetchedResultsController?.objectAtIndexPath(indexPath) as? Favourite

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}

extension FavouriteController: NSFetchedResultsControllerDelegate
{
	func controllerDidChangeContent(controller: NSFetchedResultsController)
	{
		self.fetchedResultsController?.performFetch(nil)
		
		self.tableView?.reloadData()
	}
}
