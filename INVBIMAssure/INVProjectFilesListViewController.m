//
//  INVProjectFilesListViewController.m
//  INVBIMAssure
//
//  Created by Priya Rajagopal on 10/10/14.
//  Copyright (c) 2014 Invicara Inc. All rights reserved.
//

#import "INVProjectFilesListViewController.h"
#import "INVProjectFileCollectionViewCell.h"
#import "INVProjectFileViewerController.h"

@import  CoreData;

#define CELL_WIDTH  309
#define CELL_HEIGHT 282

@interface INVProjectFilesListViewController ()<INVProjectFileCollectionViewCellDelegate>
@property (nonatomic,strong)INVProjectManager* projectManager;
@property (nonatomic,readwrite)NSFetchedResultsController* dataResultsController;
@property (nonatomic,strong)NSNumber* selectedModelId;

@end

@implementation INVProjectFilesListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.projectManager = self.globalDataManager.invServerClient.projectManager;
    
    self.title = NSLocalizedString(@"FILES", nil);
    UIColor * whiteColor = [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1.0];
    [self.view setBackgroundColor:whiteColor];
    UINib* nib = [UINib nibWithNibName:@"INVProjectFileCollectionViewCell" bundle:[NSBundle bundleForClass:[self class]]];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"ProjectFileCell"];
    // Do any additional setup after loading the view.
    UICollectionViewFlowLayout* currLayout = (UICollectionViewFlowLayout*) self.collectionView.collectionViewLayout;
    [currLayout setItemSize:CGSizeMake(CELL_WIDTH,CELL_HEIGHT)];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
 #pragma mark - UISPlitViewControllerDelegate
    [self.collectionView.collectionViewLayout invalidateLayout];
   
#pragma warning Show spinner
    [self fetchListOfProjectFiles];
    
}
#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.dataResultsController fetchedObjects].count ;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    INVProjectFileCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ProjectFileCell" forIndexPath:indexPath];
    
    // Configure the cell
    NSManagedObject* managedFileObj = [self.dataResultsController objectAtIndexPath:indexPath];
    INVFile* file = [MTLManagedObjectAdapter modelOfClass:[INVFile class] fromManagedObject:managedFileObj error:nil];
    
    cell.modelId = [self modelIdForTipOfFile:file];
    cell.fileName.text = file.fileName;
    cell.delegate = self;
    
#pragma warning - get the thumbnail image from server and update asynchronously. For now pick from bundle
    NSString* thumbNailFile = [file.fileName stringByReplacingOccurrencesOfString:@"epk" withString:@"png"];
    cell.fileThumbnail.image = [UIImage imageNamed:thumbNailFile];
#pragma warning - eventually deal with file versions
    return cell;
}

#pragma mark <UICollectionViewDelegate>


// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}



// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}



#pragma mark - server side
-(void)fetchListOfProjectFiles {
    [self.globalDataManager.invServerClient getAllFilesForProject:self.projectId WithCompletionBlock:^(INVEmpireMobileError *error) {
        if (!error) {
#pragma warning hide spinner
#pragma note Yes - you could have directly accessed accounts from project manager. Using FetchResultsController directly makes it simpler
            NSError* dbError;
            [self.dataResultsController performFetch:&dbError];
            if (!dbError) {
                NSLog(@"%s. %@",__func__,self.dataResultsController.fetchedObjects);
                [self.collectionView reloadData];
            }
            else {
#pragma warning - display error
            }
            
        }
        else {
#pragma warning - display error
        }
    }];
}


#pragma mark - accessor
-(NSFetchedResultsController*) dataResultsController {
    if (!_dataResultsController) {
        _dataResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:self.projectManager.fetchRequestForProjectFiles managedObjectContext:self.projectManager.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        
    }
    return  _dataResultsController;
}

#pragma mark - INVProjectFileCollectionViewCellDelegate
-(void)onViewProjectFile:(id)sender {
    NSLog(@"%s",__func__);
    INVProjectFileCollectionViewCell* fileCell = (INVProjectFileCollectionViewCell*)sender;
    self.selectedModelId = fileCell.modelId;
    [self performSegueWithIdentifier:@"FileViewerSegue" sender:self];
}

-(void)onManageRuleSetsForProjectFile:(id)sender {
    NSLog(@"%s",__func__);
}




 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"FileViewerSegue"]) {

        [self.tabBarController setHidesBottomBarWhenPushed:YES];
        INVProjectFileViewerController* vc = (INVProjectFileViewerController*)segue.destinationViewController;
        vc.modelId = self.selectedModelId;
    }
 }

#pragma mark - helpers
-(NSNumber*)modelIdForTipOfFile:(INVFile*)file {
    __block INVFileVersion* tip;
    [file.fileVersions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
       // tip = [MTLManagedObjectAdapter modelOfClass:[INVFileVersion class] fromManagedObject:obj error:nil];
        tip = obj;
        if (tip.fileVersionId == file.tipId) {
            *stop = YES;
        }
    }];
    
    if (tip) {
        return tip.modelId;
    }
    else {
        return nil;
    }

}


@end
