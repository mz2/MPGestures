#import <UIKit/UIKit.h>
#import "MPDollarPGestureRecognizer.h"

@interface CustomizeViewController : UITableViewController <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate> {
    __weak IBOutlet UIPickerView *existingTypesPicker;
    __weak IBOutlet UITextField *customTypeField;
    NSMutableArray *pointCloudNames;
    NSCountedSet *pointCloudCount;
}

@property (nonatomic, strong) MPDollarPGestureRecognizer *gestureRecognizer;

- (IBAction)addToExistingType:(id)sender;
- (IBAction)addToCustomType:(id)sender;
- (IBAction)deleteAllCustomTypes:(id)sender;

@end