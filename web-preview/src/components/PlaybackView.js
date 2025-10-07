import React, { useState, useEffect, useRef } from 'react';
import styled, { keyframes } from 'styled-components';
import { motion, AnimatePresence } from 'framer-motion';

const glow = keyframes`
  0%, 100% { box-shadow: 0 0 20px rgba(255, 215, 0, 0.3); }
  50% { box-shadow: 0 0 40px rgba(255, 215, 0, 0.6); }
`;

const Container = styled.div`
  height: 100%;
  background: #000;
  position: relative;
  overflow: hidden;
`;

const VideoContainer = styled.div`
  width: 100%;
  height: 100%;
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
`;

const VideoElement = styled.video`
  width: 100%;
  height: 100%;
  object-fit: cover;
`;

const VideoPlaceholder = styled(motion.div)`
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  color: white;
  text-align: center;
`;

const PlaceholderIcon = styled(motion.div)`
  font-size: 80px;
  margin-bottom: 20px;
  opacity: 0.7;
`;

const PlaceholderText = styled.h2`
  font-size: 24px;
  font-weight: 700;
  margin: 0 0 8px 0;
  text-shadow: 0 2px 4px rgba(0,0,0,0.5);
`;

const PlaceholderSubtext = styled.p`
  font-size: 16px;
  opacity: 0.8;
  margin: 0;
`;

const OverlayContainer = styled(motion.div)`
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  pointer-events: none;
  z-index: 10;
`;

const TopOverlay = styled(motion.div)`
  position: absolute;
  top: 16px;
  left: 16px;
  right: 16px;
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
`;

const LocationOverlay = styled(motion.div)`
  background: rgba(0, 0, 0, 0.7);
  color: white;
  padding: 6px 12px;
  border-radius: 8px;
  font-size: 12px;
  font-weight: 500;
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.2);
`;

const BottomOverlay = styled(motion.div)`
  position: absolute;
  bottom: 16px;
  left: 16px;
  right: 16px;
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
`;

const RecorderInfo = styled(motion.div)`
  background: rgba(0, 0, 0, 0.8);
  color: white;
  padding: 8px 12px;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 600;
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.2);
`;

const Controls = styled(motion.div)`
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  background: linear-gradient(to top, rgba(0,0,0,0.8), transparent);
  padding: 20px;
  z-index: 20;
  pointer-events: auto;
`;

const PlayButton = styled(motion.button)`
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 80px;
  height: 80px;
  border-radius: 40px;
  background: rgba(255, 255, 255, 0.9);
  border: none;
  color: #333;
  font-size: 28px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
  backdrop-filter: blur(10px);
  z-index: 30;
  pointer-events: auto;
  transition: all 0.3s ease;
  
  &:hover {
    background: white;
    transform: translate(-50%, -50%) scale(1.1);
  }
`;

const ProgressBar = styled.div`
  width: 100%;
  height: 4px;
  background: rgba(255, 255, 255, 0.3);
  border-radius: 2px;
  margin-bottom: 16px;
  overflow: hidden;
`;

const ProgressFill = styled(motion.div)`
  height: 100%;
  background: linear-gradient(90deg, #FF6B6B 0%, #FF8E53 100%);
  border-radius: 2px;
`;

const ControlsRow = styled.div`
  display: flex;
  justify-content: space-between;
  align-items: center;
`;

const TimeDisplay = styled.div`
  color: white;
  font-size: 14px;
  font-weight: 600;
  font-family: 'Courier New', monospace;
`;

const ControlButtons = styled.div`
  display: flex;
  gap: 12px;
`;

const ControlButton = styled(motion.button)`
  width: 44px;
  height: 44px;
  border-radius: 22px;
  background: rgba(255, 255, 255, 0.2);
  border: none;
  color: white;
  font-size: 18px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  backdrop-filter: blur(10px);
  transition: all 0.3s ease;
  
  &:hover {
    background: rgba(255, 255, 255, 0.3);
    transform: scale(1.1);
  }
`;

const ClipIndicator = styled(motion.div)`
  position: absolute;
  top: 20px;
  left: 50%;
  transform: translateX(-50%);
  background: rgba(0, 0, 0, 0.8);
  color: white;
  padding: 8px 16px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 600;
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.2);
  z-index: 25;
`;

const UnlockCelebration = styled(motion.div)`
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(135deg, #FFD700 0%, #FFA500 100%);
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  z-index: 50;
`;

const CelebrationIcon = styled(motion.div)`
  font-size: 100px;
  margin-bottom: 20px;
  animation: ${glow} 2s infinite;
`;

const CelebrationTitle = styled(motion.h1)`
  color: #1a1a2e;
  font-size: 32px;
  font-weight: 800;
  margin: 0 0 12px 0;
  text-align: center;
  text-shadow: 0 2px 4px rgba(0,0,0,0.2);
`;

const CelebrationSubtitle = styled(motion.p)`
  color: #1a1a2e;
  font-size: 18px;
  margin: 0 0 30px 0;
  text-align: center;
  opacity: 0.8;
`;

const PlayStoryButton = styled(motion.button)`
  background: #1a1a2e;
  color: white;
  border: none;
  padding: 16px 32px;
  border-radius: 25px;
  font-size: 18px;
  font-weight: 700;
  cursor: pointer;
  box-shadow: 0 8px 32px rgba(26, 26, 46, 0.4);
  
  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 12px 40px rgba(26, 26, 46, 0.5);
  }
`;

const BackButton = styled(motion.button)`
  position: absolute;
  top: 20px;
  left: 20px;
  background: rgba(0, 0, 0, 0.7);
  border: none;
  color: white;
  width: 44px;
  height: 44px;
  border-radius: 22px;
  font-size: 18px;
  cursor: pointer;
  z-index: 40;
  backdrop-filter: blur(10px);
  pointer-events: auto;
  
  &:hover {
    background: rgba(0, 0, 0, 0.8);
    transform: scale(1.1);
  }
`;

// Mock video data - Always sorted chronologically by timestamp
const mockClips = [
  {
    id: 1,
    title: "Packing up for the adventure",
    author: "Sarah",
    timestamp: "2024-08-18T10:30:00Z",
    dateTaken: "2024-08-18T10:30:00Z", // Date when video was actually recorded
    location: "Ridgewood, NJ",
    duration: 15,
    thumbnail: null
  },
  {
    id: 2,
    title: "Road trip begins!",
    author: "Mike", 
    timestamp: "2024-08-19T08:45:00Z",
    dateTaken: "2024-08-19T08:45:00Z",
    location: "Interstate 80",
    duration: 22,
    thumbnail: null
  },
  {
    id: 3,
    title: "First stop - Grand Canyon",
    author: "Emma",
    timestamp: "2024-08-20T12:15:00Z", 
    dateTaken: "2024-08-20T12:15:00Z",
    location: "Grand Canyon, AZ",
    duration: 28,
    thumbnail: null
  }
].sort((a, b) => new Date(a.dateTaken) - new Date(b.dateTaken)); // Ensure chronological order

const PlaybackView = ({ onNavigate, capsuleTitle = "Summer Road Trip 2024" }) => {
  const [showCelebration, setShowCelebration] = useState(true);
  const [isPlaying, setIsPlaying] = useState(false);
  const [currentClip, setCurrentClip] = useState(0);
  const [progress, setProgress] = useState(0);
  const [showControls, setShowControls] = useState(true);
  const videoRef = useRef(null);

  useEffect(() => {
    // Auto-hide controls after 3 seconds
    const timer = setTimeout(() => {
      if (isPlaying) {
        setShowControls(false);
      }
    }, 3000);

    return () => clearTimeout(timer);
  }, [isPlaying, showControls]);

  useEffect(() => {
    // Simulate video progress
    if (isPlaying) {
      const interval = setInterval(() => {
        setProgress(prev => {
          const newProgress = prev + 1;
          if (newProgress >= 100) {
            handleNextClip();
            return 0;
          }
          return newProgress;
        });
      }, 200);

      return () => clearInterval(interval);
    }
  }, [isPlaying, currentClip]);

  const handlePlay = () => {
    if (showCelebration) {
      setShowCelebration(false);
    }
    setIsPlaying(!isPlaying);
    setShowControls(true);
  };

  const handleNextClip = () => {
    if (currentClip < mockClips.length - 1) {
      // Smooth transition to next clip
      setIsPlaying(false);
      
      // Brief pause for cinematic effect
      setTimeout(() => {
        setCurrentClip(currentClip + 1);
        setProgress(0);
        setIsPlaying(true);
      }, 500); // 500ms transition delay
    } else {
      // End of playback
      setIsPlaying(false);
      setCurrentClip(0);
      setProgress(0);
    }
  };

  const handlePrevClip = () => {
    if (currentClip > 0) {
      // Smooth transition to previous clip
      setIsPlaying(false);
      
      setTimeout(() => {
        setCurrentClip(currentClip - 1);
        setProgress(0);
        setIsPlaying(true);
      }, 300); // Shorter delay for backward navigation
    }
  };

  const formatTime = (seconds) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  };

  const formatDate = (timestamp) => {
    return new Date(timestamp).toLocaleDateString('en-US', {
      month: 'short',
      day: 'numeric',
      hour: 'numeric',
      minute: '2-digit'
    });
  };

  const currentClipData = mockClips[currentClip];
  const currentProgress = Math.floor((progress / 100) * currentClipData.duration);

  return (
    <Container>
      <BackButton
        onClick={() => onNavigate('capsuleDetail')}
        whileHover={{ scale: 1.1 }}
        whileTap={{ scale: 0.95 }}
      >
        ←
      </BackButton>

      <VideoContainer onClick={() => setShowControls(!showControls)}>
        {!showCelebration ? (
          <VideoPlaceholder
            key={currentClip} // Key change triggers re-animation for clip transitions
            initial={{ opacity: 0, scale: 0.95 }}
            animate={{ opacity: 1, scale: 1 }}
            exit={{ opacity: 0, scale: 1.05 }}
            transition={{ duration: 0.8, ease: "easeInOut" }}
          >
            <PlaceholderIcon
              initial={{ scale: 0, rotate: -180 }}
              animate={{
                scale: [1, 1.1, 1],
                rotate: [0, 5, -5, 0]
              }}
              transition={{
                scale: { delay: 0.2 },
                rotate: { duration: 3, repeat: Infinity, delay: 0.5 }
              }}
            >
              🎬
            </PlaceholderIcon>
            <PlaceholderText
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.4 }}
            >
              Playing: {currentClipData.title}
            </PlaceholderText>
            <PlaceholderSubtext
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.6 }}
            >
              by {currentClipData.author}
            </PlaceholderSubtext>
          </VideoPlaceholder>
        ) : null}
        
        {!isPlaying && !showCelebration && (
          <PlayButton
            onClick={handlePlay}
            initial={{ scale: 0 }}
            animate={{ scale: 1 }}
            transition={{ type: "spring", stiffness: 200 }}
            whileHover={{ scale: 1.1 }}
            whileTap={{ scale: 0.9 }}
          >
            ▶️
          </PlayButton>
        )}
      </VideoContainer>

      {!showCelebration && (
        <>
          <OverlayContainer
            initial={{ opacity: 0 }}
            animate={{ opacity: showControls ? 1 : 0.3 }}
            transition={{ duration: 0.3 }}
          >
            <TopOverlay>
              <LocationOverlay
                initial={{ opacity: 0, y: -20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.5 }}
              >
                {currentClipData.location}
              </LocationOverlay>
            </TopOverlay>
            
            <BottomOverlay>
              <RecorderInfo
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.5 }}
              >
                {currentClipData.author} • {formatDate(currentClipData.timestamp)}
              </RecorderInfo>
            </BottomOverlay>
          </OverlayContainer>

          <ClipIndicator
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.3 }}
          >
            {currentClip + 1} of {mockClips.length}
          </ClipIndicator>

          <AnimatePresence>
            {showControls && (
              <Controls
                initial={{ opacity: 0, y: 50 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: 50 }}
                transition={{ duration: 0.3 }}
              >
                <ProgressBar>
                  <ProgressFill
                    initial={{ width: "0%" }}
                    animate={{ width: `${progress}%` }}
                    transition={{ duration: 0.2 }}
                  />
                </ProgressBar>
                
                <ControlsRow>
                  <TimeDisplay>
                    {formatTime(currentProgress)} / {formatTime(currentClipData.duration)}
                  </TimeDisplay>
                  
                  <ControlButtons>
                    <ControlButton
                      onClick={handlePrevClip}
                      whileHover={{ scale: 1.1 }}
                      whileTap={{ scale: 0.9 }}
                      disabled={currentClip === 0}
                      style={{ opacity: currentClip === 0 ? 0.5 : 1 }}
                    >
                      ⏮
                    </ControlButton>
                    
                    <ControlButton
                      onClick={handlePlay}
                      whileHover={{ scale: 1.1 }}
                      whileTap={{ scale: 0.9 }}
                    >
                      {isPlaying ? '⏸' : '▶️'}
                    </ControlButton>
                    
                    <ControlButton
                      onClick={handleNextClip}
                      whileHover={{ scale: 1.1 }}
                      whileTap={{ scale: 0.9 }}
                      disabled={currentClip === mockClips.length - 1}
                      style={{ opacity: currentClip === mockClips.length - 1 ? 0.5 : 1 }}
                    >
                      ⏭
                    </ControlButton>
                  </ControlButtons>
                </ControlsRow>
              </Controls>
            )}
          </AnimatePresence>
        </>
      )}

      <AnimatePresence>
        {showCelebration && (
          <UnlockCelebration
            initial={{ opacity: 0, scale: 0.8 }}
            animate={{ opacity: 1, scale: 1 }}
            exit={{ opacity: 0, scale: 0.8 }}
            transition={{ duration: 0.8, type: "spring" }}
          >
            <CelebrationIcon
              initial={{ scale: 0, rotate: -180 }}
              animate={{ scale: 1, rotate: 0 }}
              transition={{ delay: 0.3, type: "spring", stiffness: 200 }}
            >
              🎉
            </CelebrationIcon>
            
            <CelebrationTitle
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.6 }}
            >
              {capsuleTitle} Unlocked!
            </CelebrationTitle>
            
            <CelebrationSubtitle
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.8 }}
            >
              Your story is ready to watch
            </CelebrationSubtitle>
            
            <PlayStoryButton
              onClick={handlePlay}
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 1 }}
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
            >
              ▶️ Play Your Story
            </PlayStoryButton>
          </UnlockCelebration>
        )}
      </AnimatePresence>
    </Container>
  );
};

export default PlaybackView;