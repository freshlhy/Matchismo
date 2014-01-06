//
//  CardMatchingGame.m
//  Matchismo
//
//  Created by freshlhy on 12/17/13.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import "CardMatchingGame.h"

@interface CardMatchingGame()
@property (nonatomic, readwrite) NSUInteger score;
@property (nonatomic, readwrite) NSInteger mode;
@property (nonatomic, readwrite) NSInteger choosedCount;
@property (nonatomic, strong) NSMutableArray *cards;
@end

@implementation CardMatchingGame

- (NSMutableArray *)cards
{
    if (!_cards) _cards = [[NSMutableArray alloc] init];
    return _cards;
}

- (instancetype)initWithCardCount:(NSUInteger)count
                          setMode:(NSUInteger)mode
                        usingDeck:(Deck *)deck {
    self = [super init]; // super's designated initializer

    
    if (self) {
        for (int i = 0; i < count; i++) {
            Card *randomCard = [deck drawRandomCard];
            if (randomCard) {
                [self.cards addObject:randomCard];
            } else {
                self = nil;
                break;
            }

        }
        self.mode = mode;
        self.choosedCount = 0;
    }
    
    return self;
}

- (Card *)cardAtIndex:(NSUInteger)index
{
    return (index < [self.cards count]) ? self.cards[index] : nil;
}

static const int MISMATCH_PENALTY = 2;
static const int MATCH_BONUS = 4;
static const int COST_TO_CHOOSE = 1;

- (void)chooseCardAtIndex:(NSUInteger)index
{
    Card *card = [self cardAtIndex:index];
    // 2 card match
    if (self.mode == 0) {
        if (!card.isMatched) {
            if (card.isChosen) {
                card.chosen = NO;
            } else {
                // match against other chosen cards
                for (Card *otherCard in self.cards) {
                    if (otherCard.isChosen && !otherCard.isMatched) {
                        int matchScore = [card match:@[otherCard]];
                        if (matchScore) {
                            self.score += matchScore * MATCH_BONUS;
                            otherCard.matched = YES;
                            card.matched = YES;
                        } else {
                            self.score -= MISMATCH_PENALTY;
                            otherCard.chosen = NO;
                        }
                        break;
                    }
                }
                self.score -= COST_TO_CHOOSE;
                card.chosen = YES;
            }
        }
    }
    // 3 card match
    if (self.mode == 1) {
        self.choosedCount++;
        if (!card.isMatched) {
            if (card.isChosen) {
                card.chosen = NO;
                self.choosedCount--;
            } else {
                if (self.choosedCount == 3) {
                    // match against other chosen cards
                    Card *anotherCard = nil;
                    for (Card *otherCard in self.cards) {
                        if (otherCard.isChosen && !otherCard.isMatched) {
                            if (anotherCard) {
                                int matchScore = [card match:@[otherCard, anotherCard]];
                                
                                break;
                            }
                            anotherCard = otherCard;
                        }
                    }
                    
                }
            }
        }
    }
}

@end
