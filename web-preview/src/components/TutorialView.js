import React, { useState, useEffect } from 'react';
import styled, { keyframes } from 'styled-components';
import { motion, AnimatePresence } from 'framer-motion';

const shimmer = keyframes`
  0% { transform: translateX(-100%); }
  100% { transform: translateX(100%); }
`;

const pulse = keyframes`
  0%, 100% { opacity: 0.8; }
  50% { opacity: 1; }
`;

const Container = styled.div`
  height: 100%;
  background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
  display: flex;
  flex-direction: column;
  overflow: hidden;
  position: relative;
`;

const FilmGrainOverlay = styled.div`
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: 
    radial-gradient(circle at 20% 50%, transparent 20%, rgba(255,255,255,0.005) 21%, rgba(255,255,255,0.005) 34%, transparent 35%, transparent),
    linear-gradient(0deg, transparent 24%, rgba(255,255,255,0.01) 25%, rgba(255,255,255,0.01) 26%, transparent 27%, transparent 74%, rgba(255,255,255,0.01) 75%, rgba(255,255,255,0.01) 76%, transparent 77%, transparent);
  pointer-events: none;
  mix-blend-mode: overlay;
`;

const Header = styled.div`
  padding: 24px 20px 16px;
  text-align: center;
  position: relative;
  z-index: 2;
`;

const Title = styled(motion.h2)`
  color: white;
  font-size: 28px;
  font-weight: 800;
  margin: 0 0 8px 0;
  text-shadow: 0 4px 8px rgba(0,0,0,0.5);
  letter-spacing: -0.5px;
`;

const Subtitle = styled(motion.p)`
  color: rgba(255, 255, 255, 0.8);
  font-size: 16px;
  margin: 0;
  text-shadow: 0 2px 4px rgba(0,0,0,0.3);
`;

const CardContainer = styled.div`
  flex: 1;
  padding: 0 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  z-index: 2;
`;

const TutorialCard = styled(motion.div)`
  background: rgba(255, 255, 255, 0.95);
  border-radius: 24px;
  padding: 40px 30px;
  text-align: center;
  max-width: 300px;
  width: 100%;
  box-shadow: 
    0 24px 48px rgba(0, 0, 0, 0.3),
    0 8px 16px rgba(0, 0, 0, 0.2);
  backdrop-filter: blur(20px);
  border: 1px solid rgba(255, 255, 255, 0.2);
  position: relative;
  overflow: hidden;
`;

const CardShimmer = styled.div`
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(
    90deg,
    transparent,
    rgba(255, 255, 255, 0.2),
    transparent
  );
  animation: ${shimmer} 3s infinite;
  opacity: 0.5;
`;

const StepNumber = styled(motion.div)`
  width: 48px;
  height: 48px;
  border-radius: 24px;
  background: linear-gradient(135deg, #FF6B6B 0%, #FF8E53 100%);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 800;
  margin: 0 auto 24px auto;
  font-size: 18px;
  box-shadow: 0 8px 16px rgba(255, 107, 107, 0.4);
`;

const StepIcon = styled(motion.div)`
  font-size: 56px;
  margin-bottom: 24px;
  filter: drop-shadow(0 4px 8px rgba(0,0,0,0.1));
`;

const StepTitle = styled(motion.h3)`
  color: #1a1a2e;
  font-size: 24px;
  font-weight: 800;
  margin: 0 0 16px 0;
  letter-spacing: -0.5px;
`;

const StepDescription = styled(motion.p)`
  color: #555;
  font-size: 16px;
  line-height: 1.5;
  margin: 0 0 24px 0;
  font-weight: 400;
`;

const DemoContainer = styled(motion.div)`
  margin: 20px 0;
`;

const ExampleVideo = styled(motion.div)`
  width: 100%;
  height: 140px;
  background: linear-gradient(135deg, #000 0%, #1a1a1a 100%);
  border-radius: 16px;
  margin: 16px 0;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 32px;
  position: relative;
  overflow: hidden;
  box-shadow: 0 8px 24px rgba(0,0,0,0.3);
`;

const PlayButton = styled(motion.div)`
  position: absolute;
  width: 48px;
  height: 48px;
  border-radius: 24px;
  background: rgba(255, 255, 255, 0.95);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
  color: #333;
  box-shadow: 0 4px 16px rgba(0,0,0,0.2);
`;

const CountdownDisplay = styled(motion.div)`
  text-align: center;
  padding: 20px;
`;

const CountdownText = styled(motion.div)`
  color: rgba(255,255,255,0.9);
  font-size: 16px;
  font-weight: 600;
  margin-bottom: 8px;
`;

const CountdownTime = styled(motion.div)`
  color: rgba(255,255,255,0.7);
  font-size: 14px;
`;

const CountdownNumber = styled(motion.div)`
  font-size: 48px;
  font-weight: 800;
  color: #FFD700;
  margin-bottom: 8px;
  text-shadow: 0 2px 8px rgba(255, 215, 0, 0.3);
`;

const CountdownLabel = styled.div`
  color: #666;
  font-size: 14px;
  font-weight: 600;
`;

const LockIcon = styled(motion.div)`
  font-size: 40px;
  margin-bottom: 16px;
  filter: drop-shadow(0 4px 8px rgba(255, 215, 0, 0.3));
`;

const ContributorsDemo = styled.div`
  padding: 16px 0;
`;

const AvatarRow = styled(motion.div)`
  display: flex;
  justify-content: center;
  gap: 12px;
  margin: 20px 0;
`;

const InviteText = styled(motion.div)`
  color: rgba(255,255,255,0.8);
  font-size: 12px;
  text-align: center;
  margin-top: 10px;
`;

const Avatar = styled(motion.div)`
  width: 40px;
  height: 40px;
  border-radius: 20px;
  background: ${props => props.color};
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 18px;
  box-shadow: 0 4px 12px rgba(0,0,0,0.2);
  border: 2px solid white;
`;

const TimelineDemo = styled(motion.div)`
  display: flex;
  justify-content: center;
  gap: 6px;
  margin: 16px 0;
`;

const TimelineClip = styled(motion.div)`
  width: 24px;
  height: 16px;
  background: ${props => props.color};
  border-radius: 4px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.2);
`;

const PlaybackOverlay = styled.div`
  position: absolute;
  bottom: 12px;
  left: 12px;
  right: 12px;
  display: flex;
  justify-content: space-between;
  align-items: center;
`;

const PlaybackInfo = styled.div`
  background: rgba(0,0,0,0.8);
  padding: 4px 8px;
  border-radius: 6px;
  font-size: 10px;
  color: white;
  backdrop-filter: blur(4px);
`;

const Navigation = styled.div`
  padding: 24px 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  position: relative;
  z-index: 2;
`;

const DotsIndicator = styled.div`
  display: flex;
  gap: 10px;
`;

const Dot = styled(motion.div)`
  width: 10px;
  height: 10px;
  border-radius: 5px;
  background: ${props => props.active ? 'rgba(255, 255, 255, 0.9)' : 'rgba(255, 255, 255, 0.3)'};
  box-shadow: ${props => props.active ? '0 2px 8px rgba(255,255,255,0.3)' : 'none'};
  cursor: pointer;
`;

const NavButton = styled(motion.button)`
  background: rgba(255, 255, 255, 0.15);
  border: none;
  color: white;
  padding: 12px 24px;
  border-radius: 24px;
  font-weight: 600;
  cursor: pointer;
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.2);
  transition: all 0.3s ease;
  
  &:hover {
    background: rgba(255, 255, 255, 0.25);
    transform: translateY(-1px);
  }
  
  &.primary {
    background: linear-gradient(135deg, #FF6B6B 0%, #FF8E53 100%);
    box-shadow: 0 8px 16px rgba(255, 107, 107, 0.4);
    
    &:hover {
      transform: translateY(-2px);
      box-shadow: 0 12px 24px rgba(255, 107, 107, 0.5);
    }
  }
  
  &:disabled {
    opacity: 0.5;
    cursor: not-allowed;
    transform: none !important;
  }
`;

const tutorialSteps = [
  {
    icon: "👥",
    title: "Invite Your People",
    description: "Invite friends, spouses, or family members to your TCC group",
    demo: "invite"
  },
  {
    icon: "📅",
    title: "Select Capsule Date",
    description: "Choose when everyone can watch the collective video in chronological order",
    demo: "date"
  },
  {
    icon: "🎬",
    title: "Take & Upload Videos",
    description: "Capture through the app or upload from your phone/computer—auto-sorted chronologically by when you took the video",
    demo: "recording"
  },
  {
    icon: "🎭",
    title: "Watch & Feel the Nostalgia",
    description: "Experience everyone's point of view. What videos did you take? What videos were of you? How were you speaking, talking, moving...",
    demo: "nostalgia"
  }
];

const TutorialView = ({ onComplete }) => {
  const [currentStep, setCurrentStep] = useState(0);
  const [countdown, setCountdown] = useState(127);

  useEffect(() => {
    const interval = setInterval(() => {
      setCountdown(prev => prev > 0 ? prev - 1 : 127);
    }, 2000);
    return () => clearInterval(interval);
  }, []);

  const nextStep = () => {
    console.log('nextStep called, currentStep:', currentStep, 'tutorialSteps.length:', tutorialSteps.length);
    if (currentStep < tutorialSteps.length - 1) {
      setCurrentStep(currentStep + 1);
    } else {
      console.log('Tutorial completing, calling onComplete()');
      // Force navigation to capsule dashboard
      if (onComplete) {
        onComplete();
      } else {
        console.error('onComplete function is not provided!');
      }
    }
  };

  const prevStep = () => {
    if (currentStep > 0) {
      setCurrentStep(currentStep - 1);
    }
  };

  const goToStep = (step) => {
    setCurrentStep(step);
  };

  const renderDemo = (type) => {
    switch (type) {
      case 'invite':
        return (
          <ContributorsDemo>
            <AvatarRow>
              {['#FF6B6B', '#4ECDC4', '#45B7D1'].map((color, i) => (
                <Avatar
                  key={i}
                  color={color}
                  initial={{ scale: 0, opacity: 0 }}
                  animate={{ scale: 1, opacity: 1 }}
                  transition={{ delay: i * 0.2 }}
                  whileHover={{ scale: 1.1 }}
                >
                  👤
                </Avatar>
              ))}
              <Avatar
                color="#6C5CE7"
                initial={{ scale: 0, opacity: 0 }}
                animate={{ scale: 1, opacity: 1 }}
                transition={{ delay: 0.8 }}
                style={{ border: '2px dashed rgba(255,255,255,0.3)' }}
              >
                +
              </Avatar>
            </AvatarRow>
            <InviteText>Send invites to build your memory circle</InviteText>
          </ContributorsDemo>
        );
      case 'date':
        return (
          <CountdownDisplay>
            <LockIcon
              animate={{ rotate: [0, 5, -5, 0] }}
              transition={{ duration: 3, repeat: Infinity }}
            >
              📅
            </LockIcon>
            <CountdownText>Choose your unlock date</CountdownText>
            <CountdownTime>Set the anticipation...</CountdownTime>
          </CountdownDisplay>
        );
      case 'recording':
        return (
          <DemoContainer>
            <ExampleVideo
              initial={{ scale: 0.9, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              transition={{ delay: 0.3 }}
            >
              📱
              <PlayButton
                animate={{ scale: [1, 1.1, 1] }}
                transition={{ duration: 1.5, repeat: Infinity }}
              >
                ▶️
              </PlayButton>
            </ExampleVideo>
          </DemoContainer>
        );
        
      case 'sealed':
        return (
          <CountdownDisplay>
            <LockIcon
              animate={{ rotate: [0, 5, -5, 0] }}
              transition={{ duration: 3, repeat: Infinity }}
            >
              🔒
            </LockIcon>
            <CountdownNumber
              key={countdown}
              initial={{ scale: 1.2, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              transition={{ duration: 0.3 }}
            >
              {countdown}
            </CountdownNumber>
            <CountdownLabel>days left</CountdownLabel>
          </CountdownDisplay>
        );
        
      case 'contributors':
        return (
          <ContributorsDemo>
            <AvatarRow>
              {['#FF6B6B', '#4ECDC4', '#45B7D1'].map((color, i) => (
                <Avatar
                  key={color}
                  color={color}
                  initial={{ scale: 0, rotate: -180 }}
                  animate={{ scale: 1, rotate: 0 }}
                  transition={{ delay: i * 0.2, type: "spring" }}
                >
                  {['👩', '👨', '😊'][i]}
                </Avatar>
              ))}
            </AvatarRow>
            <TimelineDemo>
              {['#FF6B6B', '#4ECDC4', '#FF6B6B', '#45B7D1', '#4ECDC4'].map((color, i) => (
                <TimelineClip
                  key={i}
                  color={color}
                  initial={{ height: 0 }}
                  animate={{ height: 16 }}
                  transition={{ delay: i * 0.3 }}
                />
              ))}
            </TimelineDemo>
          </ContributorsDemo>
        );
        
      case 'nostalgia':
        return (
          <DemoContainer>
            <ExampleVideo
              initial={{ scale: 0.9, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              transition={{ delay: 0.3 }}
              style={{ background: 'linear-gradient(45deg, #2d1b69, #11998e)' }}
            >
              🎭
              <PlayButton
                animate={{ 
                  scale: [1, 1.1, 1],
                  opacity: [0.8, 1, 0.8]
                }}
                transition={{ 
                  duration: 2,
                  repeat: Infinity
                }}
              >
                ✨
              </PlayButton>
              <PlaybackOverlay>
                <PlaybackInfo>Your perspective</PlaybackInfo>
                <PlaybackInfo>Their view of you</PlaybackInfo>
              </PlaybackOverlay>
            </ExampleVideo>
          </DemoContainer>
        );
        
      default:
        return null;
    }
  };

  const step = tutorialSteps[currentStep];

  return (
    <Container>
      <FilmGrainOverlay />
      
      <Header>
        <Title
          initial={{ opacity: 0, y: -20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6 }}
        >
          How it works
        </Title>
        <Subtitle
          initial={{ opacity: 0, y: -20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.2 }}
        >
          Create memories that unlock over time
        </Subtitle>
      </Header>

      <CardContainer>
        <AnimatePresence mode="wait">
          <TutorialCard
            key={currentStep}
            initial={{ opacity: 0, x: 100, rotateY: 90 }}
            animate={{ opacity: 1, x: 0, rotateY: 0 }}
            exit={{ opacity: 0, x: -100, rotateY: -90 }}
            transition={{ 
              duration: 0.6,
              type: "spring",
              stiffness: 100,
              damping: 20
            }}
          >
            <CardShimmer />
            
            <StepNumber
              initial={{ scale: 0 }}
              animate={{ scale: 1 }}
              transition={{ delay: 0.3, type: "spring" }}
            >
              {currentStep + 1}
            </StepNumber>
            
            <StepIcon
              initial={{ scale: 0, rotate: -180 }}
              animate={{ scale: 1, rotate: 0 }}
              transition={{ delay: 0.4, type: "spring" }}
            >
              {step.icon}
            </StepIcon>
            
            <StepTitle
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.5 }}
            >
              {step.title}
            </StepTitle>
            
            <StepDescription
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.6 }}
            >
              {step.description}
            </StepDescription>
            
            {renderDemo(step.demo)}
          </TutorialCard>
        </AnimatePresence>
      </CardContainer>

      <Navigation>
        <NavButton 
          onClick={prevStep}
          disabled={currentStep === 0}
          whileHover={{ scale: 1.05 }}
          whileTap={{ scale: 0.95 }}
        >
          Previous
        </NavButton>
        
        <DotsIndicator>
          {tutorialSteps.map((_, index) => (
            <Dot 
              key={index} 
              active={index === currentStep}
              onClick={() => goToStep(index)}
              whileHover={{ scale: 1.2 }}
              whileTap={{ scale: 0.9 }}
            />
          ))}
        </DotsIndicator>
        
        <NavButton 
          className="primary"
          onClick={nextStep}
          whileHover={{ scale: 1.05 }}
          whileTap={{ scale: 0.95 }}
        >
          {currentStep === tutorialSteps.length - 1 ? 'Start Using TCC' : 'Next'}
        </NavButton>
      </Navigation>
    </Container>
  );
};

export default TutorialView;