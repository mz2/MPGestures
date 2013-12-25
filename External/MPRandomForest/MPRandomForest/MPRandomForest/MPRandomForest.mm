//
//  MPRandomForest.m
//  MPRandomForest
//
//  Created by Matias Piipari on 25/12/2013.
//  Copyright (c) 2013 Manuscripts.app Limited. All rights reserved.
//

#import "MPRandomForest.h"

#import "MPDataSet.h"
#import "MPDataSetTransformer.h"

#import <ALGLIB/ALGLIB.h>

#include <math.h>
#include <iostream>

@interface MPDatumClassifier ()
@end

@interface MPRandomForestClassifier ()
@property (readwrite) alglib::ae_int_t *classifierInfo;
@property (readwrite) alglib::decisionforest *classifierForest;
@property (readwrite) alglib::dfreport *classifierReport;
@end

@implementation MPDatumClassifier

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"MPInvalidInitException"
                                   reason:nil userInfo:nil];
}

- (instancetype)initWithTransformer:(id<MPDataSetTransformer>)transformer
                               data:(id<MPDataSet>)data
{
    self = [super init];
    if (self)
    {
        
    }
    
    return self;
}

- (NSArray *)posteriorProbabilitiesForClassifyingDatum:(MPDatum *)datum
{
    @throw [NSException exceptionWithName:@"MPAbstractMethodException"
                                   reason:nil userInfo:nil];
}
@end

@implementation MPRandomForestClassifier

- (alglib::real_2d_array *)ALGLIBDataForDataSet:(id<MPDataSet>)data
                           includeClassVariable:(BOOL)includeClassVariable
{
    NSUInteger fCount = self.transformer.featureCount;

    alglib::real_2d_array *array = new alglib::real_2d_array;
    array->setlength(data.datumCount,
                     includeClassVariable
                        ? fCount + 1
                        : fCount);
    
    NSUInteger shapeI = 0;
    for (NSUInteger i = 0; i < data.datumCount; i++)
    {
        id<MPDatum> datum = [data datumAtIndex:i];
        
        double *data = [self.transformer newTransform:datum];
        
        for (NSUInteger i = 0, fCount = self.transformer.featureCount; i < fCount; i++)
        {
            double val = data[i];
            (*array)(shapeI, i) = val;
        }
        
        if (includeClassVariable)
            (*array)(shapeI, fCount) = [self.transformer labelIdentifierForDatum:datum];
        
        free(data);
        shapeI++;
    }
    
    return array;
}


- (instancetype)initWithTransformer:(id<MPDataSetTransformer>)transformer
                               data:(id<MPDataSet>)data
{
    self = [super initWithTransformer:transformer data:data];
    
    if (self)
    {
        self.treeCount = MPRandomForestDefaultTreeCount;
        
        alglib::real_2d_array *xy = [self ALGLIBDataForDataSet:data includeClassVariable:YES];
        
        alglib::ae_int_t ntrees = self.treeCount;
        double r = 0.5;
        alglib::ae_int_t info;
        alglib::decisionforest *df = new alglib::decisionforest();
        alglib::dfreport *rep = new alglib::dfreport();
        
        alglib::dfbuildrandomdecisionforest(*xy,
                                            data.datumCount,
                                            self.transformer.featureCount,
                                            self.transformer.classCount,
                                            ntrees,
                                            r,
                                            info, *df, *rep);
        
        self.classifierInfo = &info;
        self.classifierForest = df;
        self.classifierReport = rep;
        
        std::cerr << "model learned    :" << info << "\n";
        std::cerr << "rms error        :" << rep->rmserror << "\n";
        std::cerr << "avg error        :" << rep->avgerror << "\n";
        std::cerr << "avg rel error    :" << rep->avgrelerror << "\n";
        std::cerr << "oob rel csl error:" << rep->oobrelclserror << "\n";
        std::cerr << "oob avg ce error :" << rep->oobavgce << "\n";
        std::cerr << "oob rms error    :" << rep->oobrmserror << "\n";
        std::cerr << "oob avg error    :" << rep->oobavgerror << "\n";
        std::cerr << "oob avg rel error:" << rep->oobavgrelerror << "\n";
    }
    
    return self;
}


- (NSArray *)posteriorProbabilitiesForClassifyingDatum:(id<MPDatum>)datum
{
    if (!datum) return NULL;
    
    double *trainingData = [self.transformer newTransform:datum];
    
    if (!trainingData) return NULL;
    
    alglib::real_1d_array *tData = new alglib::real_1d_array();
    tData->setcontent([self.transformer featureCount], trainingData);
    free(trainingData);
    
    alglib::real_1d_array *posteriorProbs = new alglib::real_1d_array();
    posteriorProbs->setlength(self.transformer.classCount);
    
    alglib::dfprocess(*(self.classifierForest), *tData, *posteriorProbs);
    
    delete tData;
    
    double *content = posteriorProbs->getcontent();
    NSMutableArray *probs = [NSMutableArray arrayWithCapacity:self.transformer.classCount];
    for (NSUInteger i = 0; i < self.transformer.featureCount; i++)
        [probs addObject:@(content[i])];
    
    delete tData;
    
    return probs;
}
@end
