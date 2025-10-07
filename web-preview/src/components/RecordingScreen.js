import React, { useState, useEffect } from 'react';
import styled from 'styled-components';
import { motion } from 'framer-motion';

const Container = styled.div`
  height: 100%;
  background: #000;
  position: relative;
  overflow: hidden;
`;

const CameraView = styled.div`
  width: 100%;
  height: 100%;
  background: linear-gradient(45deg, #333, #555);
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 48px;
  color: rgba(255, 255, 255, 0.3);
  
  ${props => props.vhsMode && `
    &::after {
      content: '';
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background: repeating-linear-gradient(
        0deg,
        transparent,
        transparent 2px,
        rgba(0, 0, 0, 0.1) 2px,
        rgba(0, 0, 0, 0.1) 4px
      );
      pointer-events: none;
      animation: vhsScanlines 0.1s linear infinite;
    }
  `}
  
  @keyframes vhsScanlines {
    0% { transform: translateY(0); }
    100% { transform: translateY(4px); }
  }
`;

const VHSNoise = styled.div`
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  opacity: ${props => props.vhsMode ? 0.05 : 0};
  background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><defs><filter id="noise"><feTurbulence baseFrequency="0.9" numOctaves="4" stitchTiles="stitch"/></filter></defs><rect width="100%" height="100%" filter="url(%23noise)" opacity="0.4"/></svg>');
  animation: ${props => props.vhsMode ? 'noiseMove 0.2s linear infinite' : 'none'};
  pointer-events: none;
  
  @keyframes noiseMove {
    0% { transform: translateX(0) translateY(0); }
    25% { transform: translateX(-1px) translateY(1px); }
    50% { transform: translateX(1px) translateY(-1px); }
    75% { transform: translateX(-1px) translateY(-1px); }
    100% { transform: translateX(1px) translateY(1px); }
  }
`;

const TopOverlays = styled.div`
  position: absolute;
  top: 16px;
  left: 16px;
  right: 16px;
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  z-index: 10;
`;

const LocationOverlay = styled.div`
  background: rgba(0, 0, 0, 0.7);
  color: white;
  padding: 6px 10px;
  border-radius: 6px;
  font-size: 12px;
  font-weight: 500;
  backdrop-filter: blur(4px);
`;

const RecordingIndicator = styled(motion.div)`
  background: rgba(0, 0, 0, 0.7);
  color: #FF3B30;
  padding: 6px 10px;
  border-radius: 6px;
  font-size: 12px;
  font-weight: 700;
  display: flex;
  align-items: center;
  gap: 6px;
  backdrop-filter: blur(4px);
`;

const RecDot = styled.div`
  width: 8px;
  height: 8px;
  background: #FF3B30;
  border-radius: 50%;
  animation: ${props => props.recording ? 'blink 1s infinite' : 'none'};
  
  @keyframes blink {
    0%, 50% { opacity: 1; }
    51%, 100% { opacity: 0; }
  }
`;

const BottomOverlays = styled.div`
  position: absolute;
  bottom: 16px;
  left: 16px;
  right: 16px;
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  z-index: 10;
`;

const TimestampOverlay = styled.div`
  background: rgba(0, 0, 0, 0.7);
  color: white;
  padding: 6px 10px;
  border-radius: 6px;
  font-size: 12px;
  font-family: 'Courier New', monospace;
  backdrop-filter: blur(4px);
`;

const RecorderNameOverlay = styled.div`
  background: rgba(0, 0, 0, 0.7);
  color: white;
  padding: 6px 10px;
  border-radius: 6px;
  font-size: 12px;
  font-weight: 500;
  backdrop-filter: blur(4px);
`;

const CapsuleSelector = styled.div`
  position: absolute;
  top: 50px;
  left: 50%;
  transform: translateX(-50%);
  background: rgba(0, 0, 0, 0.8);
  border-radius: 20px;
  padding: 8px 16px;
  display: flex;
  align-items: center;
  gap: 8px;
  z-index: 10;
`;

const CapsuleAvatars = styled.div`
  display: flex;
  margin-right: 8px;
`;

const Avatar = styled.div`
  width: 20px;
  height: 20px;
  border-radius: 10px;
  background: rgba(255, 255, 255, 0.2);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 10px;
  margin-left: -4px;
  border: 1px solid rgba(255, 255, 255, 0.3);
  
  &:first-child {
    margin-left: 0;
  }
`;

const CapsuleName = styled.span`
  color: white;
  font-size: 12px;
  font-weight: 500;
`;

const LeftToolbar = styled.div`
  position: absolute;
  left: 16px;
  top: 50%;
  transform: translateY(-50%);
  display: flex;
  flex-direction: column;
  gap: 16px;
  z-index: 10;
`;

const RightToolbar = styled.div`
  position: absolute;
  right: 16px;
  top: 50%;
  transform: translateY(-50%);
  display: flex;
  flex-direction: column;
  gap: 16px;
  z-index: 10;
`;

const ToolbarButton = styled(motion.button)`
  width: 44px;
  height: 44px;
  border-radius: 22px;
  background: rgba(0, 0, 0, 0.7);
  border: none;
  color: white;
  font-size: 18px;
  cursor: pointer;
  backdrop-filter: blur(4px);
  display: flex;
  align-items: center;
  justify-content: center;
  
  &.active {
    background: rgba(255, 255, 255, 0.9);
    color: #333;
  }
`;

const BottomControls = styled.div`
  position: absolute;
  bottom: 80px;
  left: 0;
  right: 0;
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 40px;
  z-index: 10;
`;

const ShutterButton = styled(motion.button)`
  width: 80px;
  height: 80px;
  border-radius: 40px;
  background: white;
  border: 4px solid rgba(255, 255, 255, 0.8);
  cursor: pointer;
  position: relative;
  
  &::after {
    content: '';
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    width: ${props => props.recording ? '20px' : '60px'};
    height: ${props => props.recording ? '20px' : '60px'};
    border-radius: ${props => props.recording ? '2px' : '30px'};
    background: #FF3B30;
    transition: all 0.3s ease;
  }
`;

const ProgressRing = styled.svg`
  position: absolute;
  top: -4px;
  left: -4px;
  width: 88px;
  height: 88px;
  transform: rotate(-90deg);
`;

const BackButton = styled.button`
  position: absolute;
  top: 16px;
  left: 16px;
  background: rgba(0, 0, 0, 0.7);
  border: none;
  color: white;
  width: 40px;
  height: 40px;
  border-radius: 20px;
  font-size: 18px;
  cursor: pointer;
  z-index: 20;
`;

const SaveNotification = styled(motion.div)`
  position: absolute;
  bottom: 140px;
  left: 50%;
  transform: translateX(-50%);
  background: rgba(0, 0, 0, 0.8);
  color: white;
  padding: 12px 20px;
  border-radius: 20px;
  font-size: 14px;
  display: flex;
  align-items: center;
  gap: 8px;
  z-index: 20;
`;

const RecordingScreen = ({ onNavigate, capsuleName = "Summer Road Trip" }) => {
  const [isRecording, setIsRecording] = useState(false);
  const [vhsMode, setVhsMode] = useState(true);
  const [flash, setFlash] = useState(false);
  const [currentTime, setCurrentTime] = useState(new Date());
  const [recordingProgress, setRecordingProgress] = useState(0);
  const [showSaveNotification, setShowSaveNotification] = useState(false);
  const [aspectRatio, setAspectRatio] = useState('9:16');

  useEffect(() => {
    const timer = setInterval(() => {
      setCurrentTime(new Date());
    }, 1000);
    
    return () => clearInterval(timer);
  }, []);

  useEffect(() => {
    let interval;
    if (isRecording) {
      interval = setInterval(() => {
        setRecordingProgress(prev => {
          if (prev >= 100) {
            setIsRecording(false);
            handleSave();
            return 0;
          }
          return prev + 1;
        });
      }, 100);
    } else {
      setRecordingProgress(0);
    }
    
    return () => clearInterval(interval);
  }, [isRecording]);

  const formatTimestamp = (date) => {
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    const year = date.getFullYear();
    const hours = String(date.getHours()).padStart(2, '0');
    const minutes = String(date.getMinutes()).padStart(2, '0');
    const seconds = String(date.getSeconds()).padStart(2, '0');
    
    return `${month}/${day}/${year} – ${hours}:${minutes}:${seconds}`;
  };

  const handleShutter = () => {
    if (!isRecording) {
      setIsRecording(true);
    } else {
      setIsRecording(false);
      handleSave();
    }
  };

  const handleSave = () => {
    setShowSaveNotification(true);
    setTimeout(() => {
      setShowSaveNotification(false);
    }, 2000);
  };

  const circumference = 2 * Math.PI * 38;
  const strokeDasharray = circumference;
  const strokeDashoffset = circumference - (recordingProgress / 100) * circumference;

  return (
    <Container>
      <BackButton onClick={() => onNavigate('capsuleList')}>
        ←
      </BackButton>

      <CameraView vhsMode={vhsMode}>
        📹
        <VHSNoise vhsMode={vhsMode} />
      </CameraView>

      <TopOverlays>
        <LocationOverlay>
          Ridgewood, NJ – {new Date().toLocaleDateString()}
        </LocationOverlay>
        <RecordingIndicator
          animate={isRecording ? { scale: [1, 1.05, 1] } : {}}
          transition={{ duration: 0.5, repeat: isRecording ? Infinity : 0 }}
        >
          <RecDot recording={isRecording} />
          REC
        </RecordingIndicator>
      </TopOverlays>

      <CapsuleSelector>
        <CapsuleAvatars>
          <Avatar>👩</Avatar>
          <Avatar>👨</Avatar>
          <Avatar>😊</Avatar>
        </CapsuleAvatars>
        <CapsuleName>{capsuleName}</CapsuleName>
      </CapsuleSelector>

      <LeftToolbar>
        <ToolbarButton
          className={vhsMode ? 'active' : ''}
          onClick={() => setVhsMode(!vhsMode)}
          whileHover={{ scale: 1.1 }}
          whileTap={{ scale: 0.9 }}
        >
          📼
        </ToolbarButton>
        <ToolbarButton
          className={flash ? 'active' : ''}
          onClick={() => setFlash(!flash)}
          whileHover={{ scale: 1.1 }}
          whileTap={{ scale: 0.9 }}
        >
          ⚡
        </ToolbarButton>
        <ToolbarButton
          whileHover={{ scale: 1.1 }}
          whileTap={{ scale: 0.9 }}
        >
          ⏱️
        </ToolbarButton>
      </LeftToolbar>

      <RightToolbar>
        <ToolbarButton
          whileHover={{ scale: 1.1 }}
          whileTap={{ scale: 0.9 }}
        >
          🔄
        </ToolbarButton>
        <ToolbarButton
          whileHover={{ scale: 1.1 }}
          whileTap={{ scale: 0.9 }}
        >
          📱
        </ToolbarButton>
        <ToolbarButton
          onClick={() => {
            const ratios = ['9:16', '1:1', '16:9'];
            const currentIndex = ratios.indexOf(aspectRatio);
            setAspectRatio(ratios[(currentIndex + 1) % ratios.length]);
          }}
          whileHover={{ scale: 1.1 }}
          whileTap={{ scale: 0.9 }}
        >
          {aspectRatio === '9:16' ? '📱' : aspectRatio === '1:1' ? '⬜' : '📺'}
        </ToolbarButton>
      </RightToolbar>

      <BottomControls>
        <ToolbarButton
          onClick={() => onNavigate('upload')}
          whileHover={{ scale: 1.1 }}
          whileTap={{ scale: 0.9 }}
        >
          📁
        </ToolbarButton>
        
        <ShutterButton
          recording={isRecording}
          onClick={handleShutter}
          whileHover={{ scale: 1.05 }}
          whileTap={{ scale: 0.95 }}
        >
          {isRecording && (
            <ProgressRing>
              <circle
                cx="44"
                cy="44"
                r="38"
                stroke="rgba(255,255,255,0.3)"
                strokeWidth="3"
                fill="none"
              />
              <circle
                cx="44"
                cy="44"
                r="38"
                stroke="#FF3B30"
                strokeWidth="3"
                fill="none"
                strokeDasharray={strokeDasharray}
                strokeDashoffset={strokeDashoffset}
                style={{ transition: 'stroke-dashoffset 0.1s linear' }}
              />
            </ProgressRing>
          )}
        </ShutterButton>
        
        <ToolbarButton
          whileHover={{ scale: 1.1 }}
          whileTap={{ scale: 0.9 }}
        >
          ⚙️
        </ToolbarButton>
      </BottomControls>

      <BottomOverlays>
        <TimestampOverlay>
          {formatTimestamp(currentTime)}
        </TimestampOverlay>
        <RecorderNameOverlay>
          Mike Y.
        </RecorderNameOverlay>
      </BottomOverlays>

      {showSaveNotification && (
        <SaveNotification
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          exit={{ opacity: 0, y: -20 }}
        >
          ✅ Saved to {capsuleName}
        </SaveNotification>
      )}
    </Container>
  );
};

export default RecordingScreen;